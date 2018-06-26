#!/bin/env bash
#
# rtm data file creator
# script to magic up a specified amount of AMD data files
# Chris Vidler Dynatrace DC RUM SME 2018 
#

### config defaults

# minutes, length of AMD data interval, typically 1 or 5.
INTERVAL=5

# minutes, duration, length of time to create data for, appropriate number of intervals are created to fill this time duration
DURATION=60

# count, servers, number of servers to create
SERVERS=100

# count, clients, number of clients to create
CLIENTS=1000

# count, urls, number of web urls to create
URLS=1000


# some fake path names to pad out URLs
PATHS="users,files,home,shop,path,index,login,logon,signout,logoff,search,admin,browse,uploads,ftp,pub,checkout"


# TODO add command line params to control these defaults.


### script

## functions


function create_timestamps() {

  # $1 interval length in minutes
  # $2 duration to create intervals for in minutes
  # $3 epoch start time, intervals are created from this time forward, optional, default is 'now'
  int=${1:-0}
  if [ $1 -le 0 ]; then return 1; fi
  dur=${2:-0}
  if [ $2 -le 0 ]; then return 1; fi
  if [ $2 -lt $1 ]; then return 1; fi

  ints=$(($2 / $1))
  #echo "ints: $ints" >&2

  startts=${3:--1}
  if [ $startts -lt 0 ]; then startts=$(date +%s); fi
  # align to start boundary
  startts=$((startts - ($startts % ($int*60))))
  #echo "startts: $startts" >&2

  for ((i=0; i<$ints; i++)) do
    echo -n "$((startts + $i*($int*60))),"
  done

  return 0
}

# TODO create_timestamps test cases
#echo "$(create_timestamps $INTERVAL $DURATION) [$?]"
#echo "$(create_timestamps -1 60) [$?]"
#echo "$(create_timestamps 1 5) [$?]"
#echo "$(create_timestamps 1 5 0) [$?]"


function ts_to_hex() {
  # converts a decimal timestamp $1 to hex

  if [ "$1" == "" ]; then return 1; fi
  if [ $1 -lt 0 ]; then return 1; fi
  if [ $1 -gt 4294967296 ]; then return 1; fi

  printf "%08x" $1

  return 0
}

# TODO ts_to_hex test cases
#echo "$(ts_to_hex) [$?]"
#echo "$(ts_to_hex 0) [$?]"
#echo "$(ts_to_hex 600) [$?]"
#echo "$(ts_to_hex 1000000000) [$?]"
#echo "$(ts_to_hex 5000000000) [$?]"


function ts_from_hex() {
  # converts a hex timestamp $1 to decimal

  if [ "$1" == "" ]; then return 1; fi
  if [ ${#1} -lt 8 ]; then return 1; fi
  if [ ${#1} -gt 8 ]; then return 1; fi
  
  printf "%d" 0x$1
  return 0
}

# TODO ts_from_hex test cases
#echo "$(ts_from_hex 0000000a) [$?]"
#echo "$(ts_from_hex 3b9aca00) [$?]"
#echo "$(ts_from_hex 00000000a) [$?]"
#echo "$(ts_from_hex 0a) [$?]"
#echo "$(ts_from_hex) [$?]"


function date_to_ts() {
  # parse a passed date $1 to a decimal timestamp. $2 if non-zero use local timezone to convert.

  if [ ${2:-0} -eq 0 ]; then u="-u"; else u=""; fi
  echo $(date -d "$1" $u +%s)
  return $?
}

# TODO date_to_ts test cases
#echo "$(date_to_ts '2001-01-01 00:00') [$?]"  # expected result 978307200
#echo "$(date_to_ts '2001-01-01 00:00' 1) [$?]"  # expected result 978267600 (when local TZ = +10)


function date_from_ts() {
  # parse epoch ts value $1 into a date string, $2 if non-zero used local timezone, otherwise UTC.
  
  if [ ${1:--1} -lt 0 ]; then return 1; fi
  if [ ${2:-0} -eq 0 ]; then u="-u"; else u=""; fi

  echo $(date $u -d "@$1" "+%Y-%m-%d %T")
  return 0

}

# TODO date_from_ts test cases
#echo "$(date_from_ts 978307200) [$?]"  # expected result 2001-01-01 00:00:00
#echo "$(date_from_ts 978267600 1) [$?]"  # expected result 2001-01-01 00:00:00 (when local TZ = +10)


# TODO combined test cases, print 12 lines, epoch (0) based, 5 minute (300 second) intervals, in decimal, hex, decoded hex (decimal again), readable date format
#IFS=,; for ts in $(create_timestamps 5 60 0); do
#  echo $ts,$(ts_to_hex $ts),$(ts_from_hex $(ts_to_hex $ts)),$(date_from_ts $ts)
#done


function randnum() {
  # return a random number limited by max value of $1

  rand=$((RANDOM % $1))
  while [ ! $rand -ge 0 ] && [ ! $rand -le $1 ]; do
    rand=$((RANDOM % $1))
  done

  echo "$rand"
  return 0
}


function create_rand_ips() {
  # generate a list (count in $1) of random IP addresses.

  if [ ${1:-0} -le 0 ]; then count=1; else count=$1; fi
  for (( i=1; i < $count+1; i++ )); do
    #echo $i
    temp+="$(randnum 255).$(randnum 255).$(randnum 255).$(randnum 255)"
    if [ $i -lt $count ]; then temp+=","; fi
  done

  echo $temp
  return 0
}

# TODO create_rand_ips test cases
#echo "$(create_rand_ips) [$?]"
#echo "$(create_rand_ips 10) [$?]"
#echo "$(create_rand_ips -10) [$?]"


function rand_pick_from_list() {
  # return one item from a CSV list $1.

  IFS="," read -ra sarr <<< "$1"
  acount=$((${#sarr[@]}))
  arand=$(randnum $acount)
  #echo "[$arand]" >&2
  echo "${sarr[$arand]}"

}


function rand_url_path() {
  # return a random 0-4 part url string/path from the CSV list $PATHS.

  count=$((RANDOM % 5))
  IFS="," read -ra sarr <<< "$PATHS"
  acount=$((${#sarr[@]}))

  for (( i=0; i<$count; i++ )); do
    arand=$(randnum $acount)
    echo -n "${sarr[$arand]}/"
  done

}


function create_rand_urls() {
  # generate a list (count in $1) of random URLs using server IP addresses in list in $2
  
  if [ ${1:-0} -le 0 ]; then count=1; else count=$1; fi

  for (( i=0; i<$count; i++ )); do
    path=$(rand_url_path)
    server=$(rand_pick_from_list $2)
    echo -n "$server,http://$server/$path;"
  done
  
}

# TODO create_rand_urls test cases
slist=$(create_rand_ips $SERVERS)
echo -e "$slist"
echo -e "$(create_rand_urls $URLS $slist) [$?]"


function create_zdata_header() {
  # produce the minimum required header information
  echo "#Producer: ndw.12.4.5.1841"
  echo "#AmdUUID: 564D1541-F5C0-9FBE-47B4-1D3C3417D6D4"
  echo "#Fields: type=L amdIp:txt linkType:int localId:int linkName:txt linkVC:txt"
  echo "#Fields: type=U srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt appType:int linkId:int tenantId:txt anlzType:int recAnlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int"
  echo "L 1.1.1.1 604 0 LAN 1.1.1.1%20LAN%Generated%Data"
}

function create_zdata_record() {
  # create a valid zdata 'U' record.
  # U serverip, clientip, intclientip, username, serverport, softwareservice, apptype, linkid (defind in 'L' record)
  # U 192.168.93.121 192.168.93.1 192.168.93.1 - 123 NTP%20[U] 17 0 - 32772 4 192 192 360 360 4 4
  echo "U $srvip $cliip $cliip - 80 HTTP 17 0 - 32772 4 $(randnum 10000) $(randnum 10000) $(randnum 10000) $(randnum 10000) $(randnum 1000) $(randnum 1000)"
}


