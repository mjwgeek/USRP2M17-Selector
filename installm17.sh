#!/bin/bash

# Variables
USRP_DIR="/opt/USRP2M17"
GIT_DIR=~/git  # Path to the cloned repository directory

# Determine the OS type based on the kernel version
KERNEL_VERSION=$(uname -r)
echo "Detected kernel version: $KERNEL_VERSION"  # Debugging output

if [[ "$KERNEL_VERSION" == *"ARCH"* ]]; then
    OS_TYPE="HAMVOIP"
    WEB_DIR="/srv/http/m17"  # HamVOIP web directory
else
    OS_TYPE="ALLSTARLINK"
    WEB_DIR="/var/www/html/m17"  # ASL web directory
fi

echo "Operating system type determined: $OS_TYPE"  # Debugging output

# Function to check and install pip requests
install_pip_requests() {
    # Install requests for Python 2.7
    if command -v python2 &> /dev/null; then
        echo "Installing requests for Python 2.7..."
        python2 -m pip install requests
    else
        echo "Python 2.7 is not installed."
    fi

    # Install requests for Python 3 (generic command works for both HamVOIP and ASL)
    if command -v pip &> /dev/null; then
        echo "Installing requests for Python 3..."
        pip install requests
    else
        echo "pip for Python 3 is not installed."
    fi
}

# Function to install packages
install_packages() {
    echo "Updating package list and installing required packages..."
    sudo pacman -Sy --noconfirm base-devel jq
    # Ensure pip is available for both versions
    sudo pacman -Sy --noconfirm python-pip python2-pip
}

# Main Installation Process
echo "Starting installation for $OS_TYPE..."

# Update package list and install required packages
install_packages

# Install pip requests
install_pip_requests

# Create the web directory
sudo mkdir -p $WEB_DIR

# Copy files from the cloned repository to the web directory
sudo cp -r * $WEB_DIR

# Clone the MMDVM_CM repository
mkdir -p $GIT_DIR
cd $GIT_DIR || { echo "Failed to change directory"; exit 1; }
git clone https://github.com/nostar/MMDVM_CM.git

cd MMDVM_CM/USRP2M17 || { echo "Failed to change directory"; exit 1; }

# Stop the USRP2M17 service if it's running
sudo systemctl stop usrp2m17.service

# Delete the existing USRP2M17.ini file to avoid conflicts
if [ -f "/opt/USRP2M17/USRP2M17.ini" ]; then
    echo "Deleting existing USRP2M17.ini..."
    sudo rm /opt/USRP2M17/USRP2M17.ini
fi

# Compile the USRP2M17 code
make
if [ $? -ne 0 ]; then
    echo "Errors occurred during compilation. Please resolve them before continuing."
    exit 1
fi

# Create necessary directories
sudo mkdir -p $USRP_DIR
sudo mkdir -p /var/log/usrp

# Move the compiled program to the correct folder (skip the INI file)
sudo cp USRP2M17 /opt/USRP2M17

# Ask for user's callsign
read -p "Enter your callsign: " callsign

# Create the USRP2M17.ini file with the specified content (common for both setups)
cat << EOF | sudo tee /opt/USRP2M17/USRP2M17.ini > /dev/null
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

# Replace "CHANGEME" with the user's callsign in the USRP2M17.ini file
sudo sed -i "s/Callsign=CHANGEME/Callsign=${callsign}/" /opt/USRP2M17/USRP2M17.ini

# Update connect.php with the user's callsign
CONNECT_PHP="$WEB_DIR/connect.php"
if [[ -f $CONNECT_PHP ]]; then
    sudo sed -i "s/Callsign=CHANGEME/Callsign=${callsign}/" $CONNECT_PHP
else
    echo "Warning: connect.php not found."
fi

# Set ownership and permissions for the web directory and relevant files
if [ "$OS_TYPE" == "HAMVOIP" ]; then
    # For HamVOIP, set specific ownership and permissions
    echo "Setting permissions for HamVOIP..."

    # Set ownership and permissions for the relevant files
    sudo chown http:http /srv/http/m17/reflector_options.txt
    sudo chown http:http /srv/http/m17/custom_reflectors.txt
    sudo chown http:http /opt/USRP2M17/USRP2M17.ini
    sudo chown http:http /opt/USRP2M17
    sudo chmod 755 /opt/USRP2M17
    sudo chmod 644 /srv/http/m17/*.txt
    sudo chmod 644 /opt/USRP2M17/USRP2M17.ini
else
    # For Allstarlink, set appropriate permissions and ownership
    echo "Setting permissions for Allstarlink..."
    sudo chown -R www-data:www-data $WEB_DIR
    sudo chmod -R 755 $WEB_DIR
    sudo chown -R www-data:www-data $USRP_DIR
    sudo chmod -R 755 $USRP_DIR
fi

# Create a new systemd unit file for USRP2M17
SYSTEMD_SERVICE="/usr/lib/systemd/system/usrp2m17.service"  # Path for the service file
cat << EOF | sudo tee $SYSTEMD_SERVICE > /dev/null
[Unit]
Description=USRP2M17 Service

[Service]
Type=simple
Restart=on-failure
RestartSec=3
ExecStart=/opt/USRP2M17/USRP2M17 /opt/USRP2M17/USRP2M17.ini
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Start the USRP2M17 service
sudo systemctl start usrp2m17.service

# Enable the service to start on boot
sudo systemctl enable usrp2m17.service

# Delete the git directory
rm -rf $GIT_DIR

echo "Installation complete and git directory removed."
