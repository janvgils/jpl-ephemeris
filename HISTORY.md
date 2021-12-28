Written by PJM on 25 January 2018

A script was needed to get ephemeris data on a daily basis from JPL and to write the data out in individual files. 
In the good old days, one would visit https://ssd.jpl.nasa.gov/horizons.cgi and manually enter the required data to save out the file containing pointing data.
The following was script was written and runs on a Raspberry PI. Make a directory called /home/pi/ephemeris which is where all the scripts / data will reside.
Ideally you will want to share this over the LAN via a SMB share, so your F1EHN tracker can pick up the ephemeris data.

```
command=$1
start_date=`date '+%C%y-%m-%d'`
end_date=`date '+%C%y-%m-%d' -d "$end_date+14 days"`
coord="SITE_COORD='e.eeeee,n.nnnnn,h.hhhhh'" //modify this line with your elevation, lat,long//
urlbase="https://ssd.jpl.nasa.gov/horizons_batch.cgi?batch=1&COMMAND='$command'&CENTER='coord'&$coord&MAKE_EPHEM='YES'&TABLE_TYPE='OBS'&STEP_SIZE='60%20m'&CAL_FORMAT='CAL'&TIME_DIGITS='MINUTES'&ANG_FORMAT='HMS'&OUT_UNITS='KM-S'&RANGE_UNITS='KM'&APPARENT='AIRLESS'&SOLAR_ELONG='0,180'&SUPPRESS_RANGE_RATE='NO'&SKIP_DAYLT='NO'&REF_SYSTEM='J2000'&CSV_FORMAT='YES'&OBJ_DATA='YES'&QUANTITIES='2,3,4,20'&START_TIME='$start_date%2000:00'&STOP_TIME='$end_date%2023:59'&REF_PLANE='ECLIPTIC'&COORD_TYPE='GEODETIC'&AIRMASS='38.0'&EXTRA_PREC='NO'&ELM_LABELS='YES'&TP_TYPE='ABSOLUTE'&R_T_S_ONLY='NO'&CA_TABLE_TYPE='STANDARD'&TCA3SG_LIMIT='14400'&CALIM_SB='0.1'&CALIM_PL='.1,.1,.1,.1,1.0,1.0,1.0,1.0,.1,.003'"
sleep 5
curl -s -k $urlbase -o /home/pi/ephemeris/tempeph.txt
select="["$command"]"
objname=`cat objects.lst |grep -Fw -- $select|awk {'print $3'}`
file="/home/pi/ephemeris/$objname$command"_60m".txt"
awk 'sub("$", "\r")' /home/pi/ephemeris/tempeph.txt > $file
chmod 666 $file
rm /home/pi/ephemeris/tempeph.txt
```

The coord line should be modified with your lat/long/height info in decimal, for example SITE_COORD='3.123,52.525,100.9998'. 
Put the above script into a file called jplget.sh and chmod +x it to make it executable. Make another file called get.sh and put the following into it.

```
/home/pi/ephemeris/jplget.sh -144
/home/pi/ephemeris/jplget.sh -139479
/home/pi/ephemeris/jplget.sh 101955
/home/pi/ephemeris/jplget.sh -61
/home/pi/ephemeris/jplget.sh -227
/home/pi/ephemeris/jplget.sh -234
/home/pi/ephemeris/jplget.sh -235
/home/pi/ephemeris/jplget.sh 299
/home/pi/ephemeris/jplget.sh 499
/home/pi/ephemeris/jplget.sh 599
/home/pi/ephemeris/jplget.sh 699
/home/pi/ephemeris/jplget.sh 162173
/home/pi/ephemeris/jplget.sh -96
/home/pi/ephemeris/jplget.sh -95
/home/pi/ephemeris/jplget.sh -121
/home/pi/ephemeris/jplget.sh -21
/home/pi/ephemeris/jplget.sh 391
/home/pi/ephemeris/jplget.sh 392
/home/pi/ephemeris/jplget.sh -74
/home/pi/ephemeris/jplget.sh -557
/home/pi/ephemeris/jplget.sh -64
```


Again chmod +x get.sh and call it via cron; it will deliver the ephemeris files into the directory /home/pi/ephemeris

The objects.lst file contains a list of spacecraft and their JPL ID's:

```
-1 [-1] Ceres
-82 [-82] Cassini
-203 [-203] Dawn
-140 [-140] EPOXI
-143 [-143] ExoMars_TGO
-139479 [-139479] Gaia
-130 [-130] Hayabusa
-37 [-37] Hayabusa2
-170 [-170] James_Webb_Space_Telescope
-61 [-61] Juno
-227 [-227] Kepler
-202 [-202] MAVEN
-41 [-41] Mars_Express
-53 [-53] Mars_Odyssey
-3 [-3] Mars_Orbiter_Mission
-74 [-74] MRO
-98 [-98] New_Horizons
-64 [-64] OSIRIS-REx
-5 [-5] Planet-C
-234 [-234] STEREO-A
-235 [-235] STEREO-B
-557 [-557] Spektr-R
-79 [-79] Spitzer
-31 [-31] Voyager1
-32 [-32] Voyager2
10 [10] Sun
199 [199] Mercury
299 [299] Venus
499 [499] Mars
599 [599] Jupiter
699 [699] Saturn
799 [799] Uranus
899 [899] Neptune
999 [999] Pluto
144 [144] ESA_SOLO
```

On executing the get.sh script, output files will be built as follows; these can then be directly accessed by your tracking software to point your antenna at DSN objects.


![image](https://user-images.githubusercontent.com/21240133/147609014-719d6ed0-93eb-44ba-9200-082a08a0c20f.png)


If you update or simplify this script to make getting JPL Ephemeris data great again, please let me know. 
If you want to run this on Mac OSX you will need to install "coreutils" which you can do with HomeBrew followed by "brew install coreutils".
