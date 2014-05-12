#pipresents-dotw
===============

This shell script is a workaraound to make KenT2's "pipresents-next" aware of the day of the week.
It's made for the Raspberry Pi


I suppose you already have a Raspberry Pi set up and Pi Presents up and running 
and also set it up as Black-Box according to the Pi Presents-manual
https://github.com/KenT2/pipresents-next

To make it work your Raspberry will need a permanent internet-connection to get the time from a server
or a Hardware-Clock. Mine is running with a RasClock:
https://www.modmypi.com/blog/installing-the-rasclock-raspberry-pi-real-time-clock



##to make this script run:
==========================

make USB-Sticks be mounted as "/media/usb"
```
sudo apt-get install usbmount
```

prepare a USB-Stick with the following file-structure
- folder "intro" - for mediafiles to run on each loop of the show
>folder "skripte" 
>>folder "pp_home"
>>>folder "pp_profiles"
>>>>folder "pp_loop"
>>>>>file ""pp_showlist"
>file "loopmaster.sh"

- for each day of the week place a .mov and/or .jpg file with naming conditions as follows in the root of the USB-Stick

...The script checks the day of the week it is

the weekdays are names 1-7 starting on Monday
	
- ...and which time it is (current periods in the script)
- _morgens (morning) (after 6:00h) 
- _mittags (noon) (between 11:00h and 15:00h) 
- _abends (evening) (between 15:00h and 22:00h) or
- _nachts (night) (between 22:00h and 06:00)
	
so for example the monday-morning files are called
-> "1_morgens.mov" and the picture "1_morgens.jpg"
	
thuesday noon would be
-> "2_mittags.mov"

###call the script on boot
type in terminal
```
sudo nano /etc/xdg/lxsession/LXDE/autostart
```
add the following line at the bottom of the file
```
@sudo bash /media/usb/skripte/loopmaster.sh
```

close file with CTRL X - confirm saving changes

###set-up cron
type in terminal
```
sudo nano /etc/crontab
```
add following lines at the end of the file
```
1 6     * * *   root    DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority bash /media/usb/skripte/loopmaster.sh >> /home/pi/cronlog.txt
1 10    * * *   root    DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority bash /media/usb/skripte/loopmaster.sh >> /home/pi/cronlog.txt
1 15    * * *   root    DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority bash /media/usb/skripte/loopmaster.sh >> /home/pi/cronlog.txt
1 22    * * *   root    DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority bash /media/usb/skripte/loopmaster.sh >> /home/pi/cronlog.txt
```

close file with CTRL X - confirm saving changes
