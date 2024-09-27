# USRP2M17-Selector
The ability to choose from a list of M17 Reflectors, and Modules, and Restart the USRP2M17 Service via a web application

## Overview

  This project provides a web interface for managing M17 reflectors using the USRP2M17 Bridge system.  

  The install script now installs and configures USRP2M17 Bridge and should work on AllStarlink 2 and HamVOIP.

## Requirements

  A web server (Apache or similar)

  PHP

  Python 3

  Have AllStarLink or HamVOIP installed and running.  I've only tested this on ASL 2.0 Beta 6.  Someone please let me know if it works on ASL3 please.  I have tested it on HamVOIP but please let me know if you have issues.

   *Please note that I used custom ports in my config because I'm using DVSwitch and I wanted ports that were not used by any of those supported modes so plan for that if you are using Allstarlink in your bridge.*
   If you want to use different ports, open and modify connect.php to the ports that reflect your rpt.conf node ports, reversed of course.  Here are my rpt.conf settings for node 1998 (my M17 Node).  This file is located in /etc/asterisk/

```   
[1998]

   rxchannel = USRP/127.0.0.1:34008:32008  ; Use the USRP channel driver. Must be enabled in modules.conf
 
     ; 127.0.0.1 = IP of the target application
     
     ; 34008 = UDP port the target application is listening on
    
     ; 32008 = UDP port ASL is listening on

   duplex = 0				; 0 = Half duplex with no telemetry tones or hang time. Ah, but Allison STILL talks!

   hangtime = 0				; squelch tail hang time 0
 
   althangtime = 0				; longer squelch tail hang time 0

   holdofftelem = 1			; Hold off all telemetry when signal is present on receiver or from connected nodes
 
    ; except when an ID needs to be done and there is a signal coming from a connected node.

   telemdefault = 0			; 0 = telemetry output off. Don't send Allison to DMR !!!!!!!!!!!!!!!!! Trust me.

   telemdynamic = 0			; 0 = disallow users to change the local telemetry setting with a COP command,

   linktolink = no				; disables forcing physical half-duplex operation of main repeater while

    ; still keeping half-duplex semantics (optional)

   nounkeyct = 1				; Set to a 1 to eliminate courtesy tones and associated delays.

   totime = 170000				; transmit time-out time (in ms) (optional, default 3 minutes 180000 ms

;END OF NODE 1998

1998 = radio@127.0.0.1:4569/1998,NONE
```



## Installation Instructions

1) Clone the Repository

       git clone https://github.com/mjwgeek/USRP2M17-Selector.git

2) Navigate to the Project Directory

       cd USRP2M17-Selector

3) Run the Installation Script. The installation script will create the necessary directory structure and set permissions.  Enter your Amateur Radio Callsign when prompted.

      Make the install.sh script executable

       chmod +x install.sh

       sudo ./install.sh

4) Updating visudo

       sudo visudo

     Add the following lines at the end for AllStarLink
    
       www-data ALL=(ALL) NOPASSWD: /var/www/html/m17/update_usrp2m17.sh

       www-data ALL=(ALL) NOPASSWD: /bin/systemctl restart usrp2m17

     Add the following lines at the end for HamVOIP
   
       http ALL=(ALL) NOPASSWD: /bin/systemctl restart usrp2m17

       http ALL=(ALL) NOPASSWD: /var/www/html/m17/update_usrp2m17.sh


     Save and exit (Ctrl+x, hit enter, Ctrl+o)

6) Navigate to http://{your-ipaddress}/m17
   
![image](https://github.com/user-attachments/assets/744dc092-36d5-4381-88a1-87fe7883f94a)


