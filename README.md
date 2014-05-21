#pipresents - day of the week - script
===============

This is a small shell script as a workaraound to make KenT2's "pipresents-next" aware of the day of the week.
It's made for the Raspberry Pi


I suppose you already have a Raspberry Pi set up and Pi Presents-next up and running 
and also set it up as Black-Box according to the Pi Presents-Manual
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

copy the files from the folder usb-device to an empty USB-Stick
which will then contain the following file-structure
>folder "intro" - for mediafiles to run on each loop of the show

>folder "skripte" 
>>folder "pp_home"
>>>folder "pp_profiles"
>>>>folder "pp_loop"
>>>>>file ""pp_showlist.json"

>>file "loopmaster.sh"

the current bash-script "loopmaster.sh" --> found in folder "skripte" <-- writes a file called "media.json" to the folder "pp_loop".
currently the script creates a pipresents-show as described below. If you want the show to be different, please refer to the manual of pipresents and change make "loopmaster.sh" write the json-file as you need it.

This is the current format of the created show:
- in the "intro"-folder you can place as many image- and videofiles with whatever filename in a format that pipresents-next can display. They'll be recognized by the script and written to media.json. These files will run at the beginning of each loop of the show regardless of day and time.
- for each day of the week (and defined time of day) place one ore none .mp4 and/or one or none .jpg file with naming conditions as follows in the root of the USB-Stick. These files will show in each loop of the show according to the defined day of the week and time of the day.

I hope this is understandable ;-)

Naming-Conditions for the mediafiles (sorry for the english/german mixup ;):

...The script checks the day of the week

- the weekdays are named 1-7 starting on Monday
 
...and which time it is (current periods in the script)

- _morgens (morning) (after 6:00h) 
- _mittags (noon) (between 11:00h and 15:00h) 
- _abends (evening) (between 15:00h and 22:00h) or
- _nachts (night) (between 22:00h and 06:00)
	
for example the monday-morning files are called
- "1_morgens.mp4" and the picture "1_morgens.jpg"
	
thuesday noon would be
- "2_mittags.mp4"

###call the script when your Pi boots
type in terminal
```
sudo nano /etc/xdg/lxsession/LXDE/autostart
```
add the following line at the bottom of the file
```
@sudo bash /media/usb/skripte/loopmaster.sh
```

close file with CTRL X - confirm saving changes

###set-up crontab
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
