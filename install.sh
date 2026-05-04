#!/bin/bash

set -u

# Variables
USRP_DIR="/opt/USRP2M17"
GIT_DIR="$HOME/git"
MMDVM_DIR="$GIT_DIR/MMDVM_CM"
SIGCONTEXT_FILE="/usr/include/asm/sigcontext.h"

# Determine OS/kernel info
KERNEL_VERSION=$(uname -r)
echo "Detected kernel version: $KERNEL_VERSION"

OS_TYPE=""
WEB_DIR=""
DEBIAN_VERSION_ID=""
DEBIAN_CODENAME=""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DEBIAN_VERSION_ID="${VERSION_ID:-}"
    DEBIAN_CODENAME="${VERSION_CODENAME:-}"
fi

if [[ "$KERNEL_VERSION" == *"ARCH"* ]]; then
    OS_TYPE="HAMVOIP"
    WEB_DIR="/srv/http/m17"
else
    OS_TYPE="ALLSTARLINK"
    WEB_DIR="/var/www/html/m17"
fi

echo "Operating system type determined: $OS_TYPE"

if [ -n "$DEBIAN_VERSION_ID" ]; then
    echo "Detected Debian version: $DEBIAN_VERSION_ID ${DEBIAN_CODENAME}"
fi

is_debian_13() {
    [ "$OS_TYPE" = "ALLSTARLINK" ] && { [ "$DEBIAN_VERSION_ID" = "13" ] || [ "$DEBIAN_CODENAME" = "trixie" ]; }
}

install_packages() {
    echo "Updating package list and installing required packages..."

    if [ "$OS_TYPE" = "HAMVOIP" ]; then
        pacman -Sy --noconfirm base-devel jq git
        pacman -Sy --noconfirm python-pip python2-pip
    else
        apt update

        if is_debian_13; then
            echo "Using Debian 13/Trixie compatible package list..."
            apt install -y \
                build-essential \
                git \
                jq \
                python3 \
                python3-pip \
                python3-requests
        else
            echo "Using legacy Debian/ASL compatible package list..."
            apt install -y \
                build-essential \
                git \
                jq \
                python3 \
                python3-pip \
                python3-requests

            # Try legacy packages only if available.
            if apt-cache show python2 >/dev/null 2>&1; then
                apt install -y python2
            else
                echo "python2 package not available; skipping."
            fi

            if apt-cache show python-pip-whl >/dev/null 2>&1; then
                apt install -y python-pip-whl
            else
                echo "python-pip-whl package not available; skipping."
            fi
        fi
    fi
}

install_pip_requests() {
    if [ "$OS_TYPE" = "HAMVOIP" ]; then
        if command -v python2 >/dev/null 2>&1; then
            echo "Installing requests for Python 2.7..."
            python2 -m pip install requests || true
        fi

        if command -v pip >/dev/null 2>&1; then
            echo "Installing requests for Python 3..."
            pip install requests || true
        fi
    else
        echo "Using Debian-packaged python3-requests; skipping system-wide pip install."
    fi
}

backup_sigcontext() {
    if [ -f "$SIGCONTEXT_FILE" ]; then
        echo "Backing up the original sigcontext.h..."
        cp "$SIGCONTEXT_FILE" "${SIGCONTEXT_FILE}.bak"
        return 0
    else
        echo "sigcontext.h not found at $SIGCONTEXT_FILE; skipping backup."
        return 1
    fi
}

modify_sigcontext() {
    if [ -f "$SIGCONTEXT_FILE" ]; then
        echo "Modifying sigcontext.h to use uint64_t instead of __uint128_t..."
        sed -i 's/__uint128_t/uint64_t/g' "$SIGCONTEXT_FILE"
    else
        echo "sigcontext.h not found; skipping modification."
    fi
}

revert_sigcontext() {
    if [ -f "${SIGCONTEXT_FILE}.bak" ]; then
        echo "Reverting sigcontext.h to its original state..."
        mv "${SIGCONTEXT_FILE}.bak" "$SIGCONTEXT_FILE"
    else
        echo "No sigcontext.h backup found; nothing to revert."
    fi
}

patch_cpp_headers() {
    echo "Checking C++ headers for Debian 13/compiler compatibility..."

    for file in *.h *.cpp; do
        [ -f "$file" ] || continue

        if grep -Eq 'uint8_t|uint16_t|uint32_t|uint64_t|int8_t|int16_t|int32_t|int64_t' "$file"; then
            if ! grep -q '#include <cstdint>' "$file"; then
                echo "Adding #include <cstdint> to $file..."
                sed -i '1i #include <cstdint>' "$file"
            fi
        fi
    done
}

clone_mmdvm_cm() {
    mkdir -p "$GIT_DIR"
    cd "$GIT_DIR" || {
        echo "Failed to change directory to $GIT_DIR"
        exit 1
    }

    if [ -d "$MMDVM_DIR/.git" ]; then
        echo "MMDVM_CM already exists; updating existing clone..."
        cd "$MMDVM_DIR" || exit 1
        git pull
    else
        if [ -d "$MMDVM_DIR" ]; then
            echo "Removing incomplete existing MMDVM_CM directory..."
            rm -rf "$MMDVM_DIR"
        fi

        echo "Cloning MMDVM_CM..."
        git clone https://github.com/nostar/MMDVM_CM.git
    fi
}

create_ini_file() {
    read -p "Enter your callsign: " callsign

    cat > /opt/USRP2M17/USRP2M17.ini << EOF
[M17 Network]
Callsign=CHANGEME
Address=81.231.241.25
Name=M17-000 A
LocalPort=32010
DstPort=17000
GainAdjustdB=3
Daemon=1
Debug=0

[USRP Network]
Address=127.0.0.1
DstPort=32008
LocalPort=34008
GainAdjustdB=3
Debug=0

[Log]
DisplayLevel=0
FileLevel=1
FilePath=/var/log/usrp/
FileRoot=USRP2M17
EOF

    sed -i "s/Callsign=CHANGEME/Callsign=${callsign}/" /opt/USRP2M17/USRP2M17.ini

    CONNECT_PHP="$WEB_DIR/connect.php"
    if [ -f "$CONNECT_PHP" ]; then
        sed -i "s/Callsign=CHANGEME/Callsign=${callsign}/" "$CONNECT_PHP"
    else
        echo "Warning: connect.php not found."
    fi
}

set_permissions() {
    if [ "$OS_TYPE" = "HAMVOIP" ]; then
        echo "Setting permissions for HamVOIP..."
        chown http:http "$WEB_DIR/reflector_options.txt" 2>/dev/null || true
        chown http:http "$WEB_DIR/custom_reflectors.txt" 2>/dev/null || true
        chown http:http /opt/USRP2M17/USRP2M17.ini
        chown http:http /opt/USRP2M17
        chmod 755 /opt/USRP2M17
        chmod 644 "$WEB_DIR"/*.txt 2>/dev/null || true
        chmod 644 /opt/USRP2M17/USRP2M17.ini
    else
        echo "Setting permissions for AllStarLink..."
        chown -R www-data:www-data "$WEB_DIR"
        chmod -R 755 "$WEB_DIR"
        chown -R www-data:www-data "$USRP_DIR"
        chmod -R 755 "$USRP_DIR"
    fi
}

create_systemd_service() {
    SYSTEMD_SERVICE="/usr/lib/systemd/system/usrp2m17.service"

    cat > "$SYSTEMD_SERVICE" << EOF
[Unit]
Description=USRP2M17 Service
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=/opt/USRP2M17/USRP2M17 /opt/USRP2M17/USRP2M17.ini
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
KillMode=process
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now usrp2m17.service
}

# Main Installation Process
echo "Starting installation for $OS_TYPE..."

install_packages
install_pip_requests

mkdir -p "$WEB_DIR"
cp -r "$(pwd)"/* "$WEB_DIR"/

clone_mmdvm_cm

cd "$MMDVM_DIR/USRP2M17" || {
    echo "Failed to change directory to $MMDVM_DIR/USRP2M17"
    exit 1
}

systemctl stop usrp2m17.service 2>/dev/null || true

SIGCONTEXT_WAS_PATCHED=0

if [ "$OS_TYPE" = "HAMVOIP" ]; then
    if backup_sigcontext; then
        modify_sigcontext
        SIGCONTEXT_WAS_PATCHED=1
    fi
else
    if is_debian_13; then
        echo "Debian 13 detected; skipping old sigcontext.h workaround."
    else
        if backup_sigcontext; then
            modify_sigcontext
            SIGCONTEXT_WAS_PATCHED=1
        fi
    fi
fi

patch_cpp_headers

make clean 2>/dev/null || true
make

if [ $? -ne 0 ]; then
    echo "Errors occurred during compilation."

    if [ "$SIGCONTEXT_WAS_PATCHED" -eq 1 ]; then
        revert_sigcontext
    fi

    exit 1
fi

if [ "$SIGCONTEXT_WAS_PATCHED" -eq 1 ]; then
    revert_sigcontext
fi

mkdir -p "$USRP_DIR"
mkdir -p /var/log/usrp

cp USRP2M17 "$USRP_DIR/"
chmod +x "$USRP_DIR/USRP2M17"

create_ini_file
set_permissions
create_systemd_service

rm -rf "$GIT_DIR"

echo "Installation complete."
echo
echo "Check service status with:"
echo "systemctl status usrp2m17.service --no-pager"
echo
echo "Check logs with:"
echo "journalctl -u usrp2m17.service -n 50 --no-pager"
