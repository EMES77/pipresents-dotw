#!/bin/bash -xv

#this script creates a json-profile for pipresents-next based on the day of the week. It checks if an image and/or a video for that day exists
#addition: the script chechs the time of the day and writes a different mediasource at 06:00 10:00 15:00 und 22:00h
#one minute after those times a cron-job calls this script. it kills its own running processes and starts them again
#the script also chechs if it is an official holiday (calculations are done for german holidays)
#THANKS to user nobbe64 at bashscripts.org (http://bashscripts.org/forum/memberlist.php?mode=viewprofile&u=1711)

#In addition it is possible to run a different show in the morning, noon, evening and night 

#all mediafiles and scripts are hosted on a USB-Device for easier Maintenance

#!!! don't forget to install the according crontabs.
#########################################

#made by KOMPAKT-film aka Martin Schulte
#contact martin@kompakt-film.de

#########################################

###kill running processs of pipresents and omxplayer##########
ps aux | grep /home/pi/pipresents/pipresents.py | awk '{ print $2 }' | xargs kill
ps aux | grep omxplayer | awk '{ print $2 }' | xargs kill
sleep 3;

#assure that cron outputs on the screen
cd $(dirname $0)
DISPLAY=:0.0 XAUTHORITY=/home/pi/.Xauthority


###variables#####################################################################

#date-variables
JAHR=$(date +"%Y")
dayoftheyear=$(date +"%j")
day=$(date +"%u")
zeit=$(date +"%H%M")

#path-variables
#mediafiles are hosted in the root of a usb-device
mediapath="/media/usb/"
#path for files that should run in every show, like logo, intro etc
additionalspath="/media/usb/intro/"
#this is the suffix for the Main-Video! Filetypes in additionalspath do not matter. Change e.g. to .mp4 if you want to run .mp4
pp_videosuffix=".mov"
#same here, change e.g. to .png if needed
bildsuffix=".jpg"
#path to the pipresents profile
profildatei="/media/usb/skripte/pp_home/pp_profiles/pp_loop/media.json"
#filename_additions for time of the day
#morning
morgens="_morgens"
#noon
mittags="_mittags"
#evening
abends="_abends"
#night
nachts="_nachts"

#duration of stills
duration=10

#holiday-array
declare -a feiertag

###preparation########################################################################

#writing the date of each execution of the script in a logfile
echo "####outpout#### loopmaster" >> /home/pi/cronlog.txt
date >> /home/pi/cronlog.txt
echo "#########" >> /home/pi/cronlog.txt

#clearing the screen and inserting some empty lines so that the output of text definitely disappears behind the video
clear > /dev/tty1
echo; echo; echo; echo; echo; echo; echo; echo; echo;






#calculation of holidays############################################################################
FORMAT="+%D"

AUSGABEFORMAT="+%j"
[ $# -eq 2 ] && AUSGABEFORMAT=$2

if [ $JAHR -gt 1581 ] ; then  D=10; M=202; FL=1; fi
if [ $JAHR -gt 1699 ] ; then  D=11; M=203; FL=0; fi
if [ $JAHR -gt 1799 ] ; then  D=12; M=203; FL=0; fi
if [ $JAHR -gt 1899 ] ; then  D=13; M=204; FL=2; fi
if [ $JAHR -gt 2099 ] ; then  D=14; M=204; FL=2; fi
if [ $JAHR -gt 2199 ] ; then  D=15; M=205; FL=1; fi
if [ $JAHR -gt 2299 ] ; then  D=16; M=206; FL=0; fi
Z=$(( $M - $(( 11 * $(( $JAHR % 19 ))))))
B=$(( $Z % 30 ))
if [ $FL -eq 1 ] && [ $B -eq 29 ] ; then B=28; fi
if [ $FL -eq 2 ] && [ $B -eq 28 ] ; then B=27; fi
if [ $FL -eq 2 ] && [ $B -eq 29 ] ; then B=28; fi
Z=$(( $JAHR + $(( $JAHR / 4 )) + $B -$D )) 
TAG=$(( 28 + $B - $(( $Z % 7 ))))
if [ $TAG -le 32 ] ; then MON=3; else MON=4; TAG=$(( $TAG - 31 )); fi

OSTERSONNTAG=`date -d "$MON/$TAG/$JAHR" 					$FORMAT`
NEUJAHRSTAG=`date -d "01/01/$JAHR" 							$FORMAT`
HL_DREI_KOENIGE=`date -d "01/06/$JAHR" 						$FORMAT`
ASCHERMITTWOCH=`date -d "$OSTERSONNTAG -46 days" 			$FORMAT`
KARFREITAG=`date -d "$OSTERSONNTAG -2 days" 				$FORMAT`
OSTERMONTAG=`date -d "$OSTERSONNTAG +1 days" 				$FORMAT`
TAD_DER_ARBEIT=`date -d "05/01/$JAHR" 						$FORMAT`
CHRISTI_HIMMELFAHRT=`date -d "$OSTERSONNTAG +39 days" 		$FORMAT`
PFINGSTSONNTAG=`date -d "$OSTERSONNTAG +49 days" 			$FORMAT`
PFINGSTMONTAG=`date -d "$OSTERSONNTAG +50 days" 			$FORMAT`
FRONLEICHNAM=`date -d "$OSTERSONNTAG +60 days" 				$FORMAT`
MARIAE_HIMMELFAHRT=`date -d "08/15/$JAHR" 					$FORMAT`
TAG_DER_DT_EINHEIT=`date -d "10/03/$JAHR" 					$FORMAT`
ALLERHEILIGEN=`date -d "11/01/$JAHR" 						$FORMAT`
WEIHNACHT=`date -d "12/24/$JAHR" 							$FORMAT`
W=`date -d "$WEIHNACHT" 									+%w`
VOLKSTRAUERTAG=`date -d "$WEIHNACHT -$(( 35 + $W )) days" 	$FORMAT`
BUSS_UND_BETTAG=`date -d "$WEIHNACHT -$(( 32 + $W )) days" 	$FORMAT`
TOTENSONTAG=`date -d "$WEIHNACHT -$(( 28 + $W )) days" 		$FORMAT`
ADVENT_1=`date -d "$WEIHNACHT -$(( 21 + $W )) days" 		$FORMAT`
ADVENT_2=`date -d "$WEIHNACHT -$(( 14 + $W )) days" 		$FORMAT`
ADVENT_3=`date -d "$WEIHNACHT -$(( 7 + $W )) days" 			$FORMAT`
ADVENT_4=`date -d "$WEIHNACHT -$W days" 					$FORMAT`
WEIHNACHT_1=`date -d "12/25/$JAHR" 							$FORMAT`
WEIHNACHT_2=`date -d "12/26/$JAHR" 							$FORMAT`
SILVESTER=`date -d "12/31/$JAHR" 							$FORMAT`


feiertag[0]=`date -d "$NEUJAHRSTAG" 			"$AUSGABEFORMAT"`
feiertag[1]=`date -d "$HL_DREI_KOENIGE" 		"$AUSGABEFORMAT"`
#feiertag[2]=`date -d "$ASCHERMITTWOCH" 		"$AUSGABEFORMAT"`
feiertag[3]=`date -d "$KARFREITAG" 				"$AUSGABEFORMAT"`
#feiertag[4]=`date -d "$OSTERSONNTAG" 			"$AUSGABEFORMAT"`
feiertag[5]=`date -d "$OSTERMONTAG" 			"$AUSGABEFORMAT"`
feiertag[6]=`date -d "$TAD_DER_ARBEIT" 			"$AUSGABEFORMAT"`
feiertag[7]=`date -d "$CHRISTI_HIMMELFAHRT"		 "$AUSGABEFORMAT"`
#feiertag[8]=`date -d "$PFINGSTSONNTAG" 		"$AUSGABEFORMAT"`
feiertag[9]=`date -d "$PFINGSTMONTAG" 			"$AUSGABEFORMAT"`
feiertag[10]=`date -d "$FRONLEICHNAM" 			"$AUSGABEFORMAT"`
#feiertag[11]=`date -d "$MARIAE_HIMMELFAHRT" 	"$AUSGABEFORMAT"`
feiertag[12]=`date -d "$TAG_DER_DT_EINHEIT" 	"$AUSGABEFORMAT"`
feiertag[13]=`date -d "$ALLERHEILIGEN" 			"$AUSGABEFORMAT"`
#feiertag[14]=`date -d "$VOLKSTRAUERTAG" 		"$AUSGABEFORMAT"`
#feiertag[15]=`date -d "$BUSS_UND_BETTAG" 		"$AUSGABEFORMAT"`
#feiertag[16]=`date -d "$TOTENSONTAG" 			"$AUSGABEFORMAT"`
#feiertag[17]=`date -d "$ADVENT_1" 				"$AUSGABEFORMAT"`
#feiertag[18]=`date -d "$ADVENT_2" 				"$AUSGABEFORMAT"`
#feiertag[19]=`date -d "$ADVENT_3" 				"$AUSGABEFORMAT"`
#feiertag[20]=`date -d "$ADVENT_4" 				"$AUSGABEFORMAT"`
feiertag[21]=`date -d "$WEIHNACHT" 				"$AUSGABEFORMAT"`
feiertag[22]=`date -d "$WEIHNACHT_1" 			"$AUSGABEFORMAT"`
feiertag[23]=`date -d "$WEIHNACHT_2" 			"$AUSGABEFORMAT"`
feiertag[24]=`date -d "$SILVESTER" 				"$AUSGABEFORMAT"`



#####check if today is a holiday###########################################
for i in "${feiertag[@]}"
do
    if [ "$i" == "$dayoftheyear" ] ; then
    	day="7"
        echo "heute ist ein feiertag"
    fi
done

########################################################################

#the following block writes a json-profile for pipresents-next.

#echo the time for the logfile
echo $zeit

#checks the time og the day and changes the paths to mediafiles accordingly
if [ $zeit -gt 600 ] && [ $zeit -lt 1000 ]; then
	infilevideo=$mediapath$day$morgens$pp_videosuffix
	infilebild=$mediapath$day$morgens$bildsuffix
elif [ $zeit -gt 1000 ] && [ $zeit -lt 1500 ]; then
	infilevideo=$mediapath$day$mittags$pp_videosuffix
	infilebild=$mediapath$day$mittags$bildsuffix
elif [ $zeit -gt 1500 ] && [ $zeit -lt 2200 ]; then
	infilevideo=$mediapath$day$abends$pp_videosuffix
	infilebild=$mediapath$day$abends$bildsuffix
elif [ $zeit -gt 2200 ] || [ $zeit -lt 600 ]; then
	infilevideo=$mediapath$day$nachts$pp_videosuffix
	infilebild=$mediapath$day$nachts$bildsuffix
fi

#just for testing, outputs to the logfile
echo $infilevideo
echo $infilebild

#write pp profildatei
echo '{'>$profildatei
echo ' "issue": "1.2",'>>$profildatei
echo ' "tracks": ['>>$profildatei
for filename in "$additionalspath"*; do
 case $filename in
 *.mov)
    echo '  {'>>$profildatei
    echo '   "animate-begin": "",'>>$profildatei
    echo '   "animate-clear": "no",'>>$profildatei
    echo '   "animate-end": "",'>>$profildatei
    echo '   "background-colour": "",'>>$profildatei
    echo '   "background-image": "",'>>$profildatei
    echo '   "display-show-background": "yes",'>>$profildatei
    echo '   "display-show-text": "no",'>>$profildatei
    echo '   "image-window": "",'>>$profildatei
    echo '   "links": "",'>>$profildatei
    echo '   "plugin": "",'>>$profildatei
    echo '   "location": "'$filename'",'>>$profildatei
    echo '   "title": "video",'>>$profildatei
    echo '   "track-ref": "",'>>$profildatei
    echo '   "omx-audio": "hdmi",'>>$profildatei
    echo '   "omx-volume": "",'>>$profildatei
    echo '   "omx-window": "",'>>$profildatei
    echo '   "show-control-begin": "",'>>$profildatei
    echo '   "show-control-end": "",'>>$profildatei
    echo '   "thumbnail": "",'>>$profildatei
    echo '   "track-text": "",'>>$profildatei 
    echo '   "track-text-colour": "",'>>$profildatei
    echo '   "track-text-font": "",'>>$profildatei
    echo '   "track-text-x": "1000",'>>$profildatei
    echo '   "track-text-y": "200",'>>$profildatei
    echo '   "type": "video"'>>$profildatei 
    echo '  },'>>$profildatei 
  ;;
  *.mp4)
    echo '  {'>>$profildatei
    echo '   "animate-begin": "",'>>$profildatei
    echo '   "animate-clear": "no",'>>$profildatei
    echo '   "animate-end": "",'>>$profildatei
    echo '   "background-colour": "",'>>$profildatei
    echo '   "background-image": "",'>>$profildatei
    echo '   "display-show-background": "yes",'>>$profildatei
    echo '   "display-show-text": "no",'>>$profildatei
    echo '   "image-window": "",'>>$profildatei
    echo '   "links": "",'>>$profildatei
    echo '   "plugin": "",'>>$profildatei
    echo '   "location": "'$filename'",'>>$profildatei
    echo '   "title": "video",'>>$profildatei
    echo '   "track-ref": "",'>>$profildatei
    echo '   "omx-audio": "hdmi",'>>$profildatei
    echo '   "omx-volume": "",'>>$profildatei
    echo '   "omx-window": "",'>>$profildatei
    echo '   "show-control-begin": "",'>>$profildatei
    echo '   "show-control-end": "",'>>$profildatei
    echo '   "thumbnail": "",'>>$profildatei
    echo '   "track-text": "",'>>$profildatei 
    echo '   "track-text-colour": "",'>>$profildatei
    echo '   "track-text-font": "",'>>$profildatei
    echo '   "track-text-x": "1000",'>>$profildatei
    echo '   "track-text-y": "200",'>>$profildatei
    echo '   "type": "video"'>>$profildatei 
    echo '  },'>>$profildatei 
  ;;
  *.jpg)
    echo '  {'>>$profildatei
    echo '   "animate-begin": "",'>>$profildatei
    echo '   "animate-clear": "no",'>>$profildatei
    echo '   "animate-end": "",'>>$profildatei
    echo '   "background-colour": "",'>>$profildatei
    echo '   "background-image": "",'>>$profildatei
    echo '   "display-show-background": "yes",'>>$profildatei
    echo '   "display-show-text": "no",'>>$profildatei
    echo '   "image-window": "",'>>$profildatei
    echo '   "links": "",'>>$profildatei
    echo '   "plugin": "",'>>$profildatei
    echo '   "show-control-begin": "",'>>$profildatei
    echo '   "show-control-end": "",'>>$profildatei
    echo '   "thumbnail": "",'>>$profildatei
    echo '   "duration": "'$duration'",'>>$profildatei
    echo '   "location": "'$filename'",'>>$profildatei
    echo '   "title": "bild",'>>$profildatei
    echo '   "track-ref": "",'>>$profildatei
    echo '   "track-text": "",'>>$profildatei 
    echo '   "track-text-colour": "",'>>$profildatei
    echo '   "track-text-font": "",'>>$profildatei
    echo '   "track-text-x": "1000",'>>$profildatei
    echo '   "track-text-y": "200",'>>$profildatei
    echo '   "transition": "cut",'>>$profildatei
    echo '   "type": "image"'>>$profildatei
    echo '  },'>>$profildatei
  ;;
  *.png)
    echo '  {'>>$profildatei
    echo '   "animate-begin": "",'>>$profildatei
    echo '   "animate-clear": "no",'>>$profildatei
    echo '   "animate-end": "",'>>$profildatei
    echo '   "background-colour": "",'>>$profildatei
    echo '   "background-image": "",'>>$profildatei
    echo '   "display-show-background": "yes",'>>$profildatei
    echo '   "display-show-text": "no",'>>$profildatei
    echo '   "image-window": "",'>>$profildatei
    echo '   "links": "",'>>$profildatei
    echo '   "plugin": "",'>>$profildatei
    echo '   "show-control-begin": "",'>>$profildatei
    echo '   "show-control-end": "",'>>$profildatei
    echo '   "thumbnail": "",'>>$profildatei
    echo '   "duration": "'$duration'",'>>$profildatei
    echo '   "location": "'$filename'",'>>$profildatei
    echo '   "title": "bild",'>>$profildatei
    echo '   "track-ref": "",'>>$profildatei
    echo '   "track-text": "",'>>$profildatei 
    echo '   "track-text-colour": "",'>>$profildatei
    echo '   "track-text-font": "",'>>$profildatei
    echo '   "track-text-x": "1000",'>>$profildatei
    echo '   "track-text-y": "200",'>>$profildatei
    echo '   "transition": "cut",'>>$profildatei
    echo '   "type": "image"'>>$profildatei
    echo '  },'>>$profildatei
  ;;
 esac
done
if [ -f $infilevideo ]
 then
 echo '  {'>>$profildatei
 echo '   "animate-begin": "",'>>$profildatei
 echo '   "animate-clear": "no",'>>$profildatei
 echo '   "animate-end": "",'>>$profildatei
 echo '   "background-colour": "",'>>$profildatei
 echo '   "background-image": "",'>>$profildatei
 echo '   "display-show-background": "yes",'>>$profildatei
 echo '   "display-show-text": "no",'>>$profildatei
 echo '   "image-window": "",'>>$profildatei
 echo '   "links": "",'>>$profildatei
 echo '   "plugin": "",'>>$profildatei
 echo '   "location": "'$infilevideo'",'>>$profildatei
 echo '   "title": "video",'>>$profildatei
 echo '   "track-ref": "",'>>$profildatei
 echo '   "omx-audio": "hdmi",'>>$profildatei
 echo '   "omx-volume": "",'>>$profildatei
 echo '   "omx-window": "",'>>$profildatei
 echo '   "show-control-begin": "",'>>$profildatei
 echo '   "show-control-end": "",'>>$profildatei
 echo '   "thumbnail": "",'>>$profildatei
 echo '   "track-text": "",'>>$profildatei 
 echo '   "track-text-colour": "",'>>$profildatei
 echo '   "track-text-font": "",'>>$profildatei
 echo '   "track-text-x": "1000",'>>$profildatei
 echo '   "track-text-y": "200",'>>$profildatei
 echo '   "type": "video"'>>$profildatei
fi
if [-f $infilevideo] && [-f $infilebild]
 then
 echo '  },'>>$profildatei
fi
if [! -f $infilebild ]
 then
 echo '  }'>>$profildatei
else
 echo '  {'>>$profildatei
 echo '   "animate-begin": "",'>>$profildatei
 echo '   "animate-clear": "no",'>>$profildatei
 echo '   "animate-end": "",'>>$profildatei
 echo '   "background-colour": "",'>>$profildatei
 echo '   "background-image": "",'>>$profildatei
 echo '   "display-show-background": "yes",'>>$profildatei
 echo '   "display-show-text": "no",'>>$profildatei
 echo '   "image-window": "",'>>$profildatei
 echo '   "links": "",'>>$profildatei
 echo '   "plugin": "",'>>$profildatei
 echo '   "show-control-begin": "",'>>$profildatei
 echo '   "show-control-end": "",'>>$profildatei
 echo '   "thumbnail": "",'>>$profildatei
 echo '   "duration": "'$duration'",'>>$profildatei
 echo '   "location": "'$infilebild'",'>>$profildatei
 echo '   "title": "bild",'>>$profildatei
 echo '   "track-ref": "",'>>$profildatei
 echo '   "track-text": "",'>>$profildatei 
 echo '   "track-text-colour": "",'>>$profildatei
 echo '   "track-text-font": "",'>>$profildatei
 echo '   "track-text-x": "1000",'>>$profildatei
 echo '   "track-text-y": "200",'>>$profildatei
 echo '   "transition": "cut",'>>$profildatei
 echo '   "type": "image"'>>$profildatei
 echo '  }'>>$profildatei
fi
echo ' ]'>>$profildatei
echo '}'>>$profildatei

#run pipresents-next 
/usr/bin/python /home/pi/pipresents/pipresents.py -o /media/usb/skripte -p pp_loop  -b -f

#for the logfile
echo "pipresents gestartet"
