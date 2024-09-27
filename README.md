# USRP2M17-Selector

The ability to choose from a list of M17 Reflectors, and Modules, and Restart the USRP2M17 Service via a web application

## Overview

  This project provides a web interface for managing M17 reflectors using the USRP2M17 Bridge system.  

  The install script now installs and configures USRP2M17 Bridge and should work on AllStarlink 2 and HamVOIP.

## Requirements

   Have AllStarLink or HamVOIP installed and running. I have tested this on AllStarLink 2.0 Beta 6, HamVOIP, and AllstarLink 3.

   Add a custom node to use for M17 traffic.

   *Please note that I used custom ports in my config because I'm using DVSwitch and I wanted ports that were not used by any of those supported modes so plan for that if you are using other ports in your system.*
   If you want to use different ports, open and modify connect.php to the ports that reflect your rpt.conf node ports, reversed of course.  Here are my rpt.conf settings for node 1998 (my M17 Node).  This file is located in /etc/asterisk/

  
 ## Asterisk Setup for Custom M17 Node
 
  ### 1)  Edit rpt.conf
     
          nano /etc/asterisk/rpt.conf

  Copy this into your file
```   
[1917]

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

   tx_timeout = 170000				; transmit time-out time (in ms) (optional, default 3 minutes 180000 ms

;END OF NODE 1917

```
   Now add this to your [nodes] stanza like this:
```
[nodes]
; Note, if you are using automatic updates for allstar link nodes,
; no allstar link nodes should be defined here. Only place a definition
; for your local (within your LAN) nodes, and private (off of allstar
; link) nodes here.

12345 = radio@127.0.0.1/12345,NONE  //This will already be your current node number so don't change it 
1917 = radio@127.0.0.1/1917,NONE  //Add this one for M17
```
  
  Save and exit (Ctrl+o, hit enter, Ctrl+x)

   
### 2) Enable the USRP module:

       nano /etc/asterisk/modules.conf
   Change noload=chan_usrp.so to load=chan_usrp.so

   Save and exit (Ctrl+o, hit enter, Ctrl+x)
   

### 4) Add new 1917 node to extensions.conf

       nano /etc/asterisk/extensions.conf
   Add this to the [radio-secure] stanza:

       exten => 1917,1,rpt,1917

AllStarLink3 Specific:  I added NODE1=1917 to [globals] like this, is it correct?  I don't know but it worked for me.  I'm new to ASL3.

```
     [globals]
      HOMENPA = 999 ; change this to your Area Code
      NODE = 123456   ; change this to your node number
      NODE1 = 1917 
```
   Save and exit (Ctrl+o, hit enter, Ctrl+x)


### 5) Restart Asterisk
   
       astres.sh

### 6) To see your new node in Supermon, Allmon2, follow those specific instructions, that goes beyond the scope of this project but it typically involves editing allmon.ini for Supermon or allmon.ini.php for allmon2 located in their respective directories in /var/www/html/ for AllStarLink or /srv/http/ for HamVOIP
   
## Installing USRP2M17 and the Selector

1) Clone the Repository

       git clone https://github.com/mjwgeek/USRP2M17-Selector.git

2) Navigate to the Project Directory

       cd USRP2M17-Selector

3) Run the Installation Script. The installation script will create the necessary directory structure and set permissions.  Enter your Amateur Radio Callsign when prompted.

      Make the install.sh script executable

       chmod +x install.sh

       sudo ./install.sh

4) Updating visudo

    A) For Allstarlink

       sudo visudo

     Add the following lines at the end for AllStarLink
    
       www-data ALL=(ALL) NOPASSWD: /var/www/html/m17/update_usrp2m17.sh

       www-data ALL=(ALL) NOPASSWD: /bin/systemctl restart usrp2m17

   B) For HamVOIP

       sudo EDITOR=nano visudo

   Add the following lines at the end for HamVOIP
   
       http ALL=(ALL) NOPASSWD: /bin/systemctl restart usrp2m17

       http ALL=(ALL) NOPASSWD: /var/www/html/m17/update_usrp2m17.sh


     Save and exit (Ctrl+o, hit enter, Ctrl+x)

  
6) Navigate to http://{your-ipaddress}/m17
   
![image](https://github.com/user-attachments/assets/744dc092-36d5-4381-88a1-87fe7883f94a)


