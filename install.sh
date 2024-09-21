#!/bin/bash

# Variables
WEB_DIR="/var/www/html/m17"
USRP_DIR="/opt/USRP2M17"
CONNECT_PHP="$WEB_DIR/connect.php"

# Update package list and install required packages
sudo apt update
sudo apt install -y python3-pip jq

# Install Python dependencies
pip3 install requests

# Create the web directory
sudo mkdir -p $WEB_DIR

# Copy files from the cloned repository to the web directory
sudo cp -r * $WEB_DIR

# Set permissions
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
