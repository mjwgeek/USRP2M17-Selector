# USRP2M17-Selector
The ability to choose from a list of M17 Reflectors, and Modules, and Restart the USRP2M17 Service via a web application

USRP2M17-Selector Documentation

Overview

  This project provides a web interface for managing M17 reflectors using the USRP2M17 Bridge system.

Requirements

  A web server (Apache or similar)

  PHP

  Python 3

  Have USRP2M17 Intsalled.  See https://wiki.m17project.org/usrp2m17_bridge

   *Please note that I used custom ports in my config because I'm using DVSwitch and I wanted ports that were not used by any of those supported modes so plan for that if you are using Allstarlink in your bridge.*
   If you want to use different ports, open and modify connect.php to the ports that reflect your rpt.conf node ports, reversed of course.  

Installation Instructions

1) Clone the Repository

       git clone https://github.com/yourusername/USRP2M17-Selector.git

2) Navigate to the Project Directory

       cd USRP2M17-Selector

3) Run the Installation Script. The installation script will create the necessary directory structure and set permissions.

      Make the install.sh script executable

       chmod+x install.sh

       sudo ./install.sh

4) Updating visudo

       sudo visudo

     Add the following lines at the end
    
       www-data ALL=(ALL) NOPASSWD: /var/www/html/m17/update_usrp2m17.sh

       www-data ALL=(ALL) NOPASSWD: /bin/systemctl restart usrp2m17

     Save and exit (Ctrl+x, hit enter, Ctrl+o)

6) Navigate to http://{your-ipaddress}/m17
   
![M17Screenshot](https://github.com/user-attachments/assets/65832674-46e8-4dc2-b52e-dc0255f36b69)

