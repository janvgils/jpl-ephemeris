#!/usr/bin/env bash

TOPDIR="${HOME}"/Apps/ephemeris

command=$1
start_date=$(date '+%C%y-%m-%d')
end_date=$(date '+%C%y-%m-%d' -d "$end_date+14 days")
coord="SITE_COORD='e.eeeee,n.nnnnn,h.hhhhh'" //modify this line with your location, lat,long,height//

urlbase="https://ssd.jpl.nasa.gov/api/horizons.api?format=text&COMMAND='$command'&CENTER='coord'&$coord&MAKE_EPHEM='YES'&TABLE_TYPE='OBS'&STEP_SIZE='60%20m'&CAL_FORMAT='CAL'&TIME_DIGITS='MINUTES'&ANG_FORMAT='HMS'&OUT_UNITS='KM-S'&RANGE_UNITS='KM'&APPARENT='AIRLESS'&SOLAR_ELONG='0,180'&SUPPRESS_RANGE_RATE='NO'&SKIP_DAYLT='NO'&REF_SYSTEM='J2000'&CSV_FORMAT='YES'&OBJ_DATA='YES'&QUANTITIES='2,3,4,20'&START_TIME='$start_date%2000:00'&STOP_TIME='$end_date%2023:59'&REF_PLANE='ECLIPTIC'&COORD_TYPE='GEODETIC'&AIRMASS='38.0'&EXTRA_PREC='NO'&ELM_LABELS='YES'&TP_TYPE='ABSOLUTE'&R_T_S_ONLY='NO'&CA_TABLE_TYPE='STANDARD'&TCA3SG_LIMIT='14400'&CALIM_SB='0.1'&CALIM_PL='.1,.1,.1,.1,1.0,1.0,1.0,1.0,.1,.003'"

sleep 5

curl -s -k "${urlbase}" -o "${TOPDIR}"/tempeph.txt
select="["$command"]"
objname=$(cat "${TOPDIR}"/objects.lst |grep -Fw -- "${select}"|awk {'print $3'})
file="${TOPDIR}/$objname$command"_60m".txt"
awk 'sub("$", "\r")' "${TOPDIR}"/tempeph.txt > $file
chmod 644 "${file}"
rm "${TOPDIR}"/tempeph.txt
