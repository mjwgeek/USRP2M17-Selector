#!/bin/bash

# Variables
WEB_DIR="/var/www/html/m17"
USRP_DIR="/opt/USRP2M17"
CONNECT_PHP="$WEB_DIR/connect.php"
SYSTEMD_SERVICE="/usr/lib/systemd/system/usrp2m17.service"  # Path for the service file
GIT_DIR=~/git  # Path to the cloned repository directory

# Update package list and install required packages
sudo apt update
sudo apt install -y build-essential python3 python3-pip jq

# Install Python dependencies
pip3 install requests

# Create the web directory
sudo mkdir -p $WEB_DIR

# Clone the MMDVM_CM repository
mkdir -p $GIT_DIR
cd $GIT_DIR || { echo "Failed to change directory"; exit 1; }
git clone https://github.com/nostar/MMDVM_CM.git

cd MMDVM_CM/USRP2M17 || { echo "Failed to change directory"; exit 1; }

# Compile the USRP2M17 code
make
if [ $? -ne 0 ]; then
    echo "Errors occurred during compilation. Please resolve them before continuing."
    exit 1
fi

# Create necessary directories
sudo mkdir -p $USRP_DIR
sudo mkdir -p /var/log/usrp

# Move the compiled program and its configuration file to the correct folder
sudo cp USRP2M17 /opt/USRP2M17
sudo cp USRP2M17.ini /opt/USRP2M17

# Create a new systemd unit file for USRP2M17
cat << EOF | sudo tee $SYSTEMD_SERVICE
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

# Set permissions for the web directory
sudo chown -R www-data:www-data $WEB_DIR
sudo chmod -R 755 $WEB_DIR
sudo chown -R www-data:www-data $USRP_DIR
sudo chmod -R 755 $USRP_DIR

# Ask for user's callsign
read -p "Enter your callsign: " callsign

# Update connect.php with the user's callsign
sudo sed -i "s/Callsign=CHANGEME/Callsign=${callsign}/" $CONNECT_PHP

# Instructions for visudo
echo "Add the following lines to your visudo file to allow www-data to run the script without a password:"
echo "www-data ALL=(ALL) NOPASSWD: /var/www/html/m17/update_usrp2m17.sh"
echo "www-data ALL=(ALL) NOPASSWD: /bin/systemctl restart usrp2m17"

# Delete the git directory
rm -rf $GIT_DIR

echo "Installation complete and git directory removed."