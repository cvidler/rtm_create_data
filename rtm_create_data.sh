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
CLIENTS=100

# count, urls, number of web urls to create
URLS=100

# count, # records to create per file
RECORDS=50


# some fake path names to pad out URLs
PATHS="users,files,home,shop,path,index,login,logon,signout,logoff,search,admin,browse,uploads,ftp,pub,checkout"


# TODO add command line params to control these defaults.


### script

## header
echo "$0 - Script to create random AMD data files with complexity"
echo "Chris Vidler Dynatrace DC RUM SME 2018"
echo ""
echo "Please wait this takes some time...."
echo ""

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


function create_rand_macs() {
  # generate a list (count in $1) of random MAC addresses.

  if [ ${1:-0} -le 0 ]; then count=1; else count=$1; fi
  for (( i=1; i < $count+1; i++ )); do
    #echo $i
    temp+="$(printf '%02X%02X%02X%02X%02X%02X' 0 $(randnum 255) $(randnum 255) $(randnum 255) $(randnum 255) $(randnum 255))"
    if [ $i -lt $count ]; then temp+=","; fi
  done

  echo $temp
  return 0
}
# TODO create_rand_macs test cases
#echo "$(create_rand_macs) [$?]"
#echo "$(create_rand_macs 10) [$?]"
#echo "$(create_rand_macs) -10 [$?]"


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
clist=$(create_rand_ips $CLIENTS)
smaclist=$(create_rand_macs $SERVERS)
cmaclist=$(create_rand_macs $CLIENTS)

#echo -e "Servers: $slist"
#echo -e "Clients: $clist"
#echo -e "Server MACs: $smaclist"
#echo -e "Client MACs: $cmaclist"
#echo -e "$(create_rand_urls $URLS $slist) [$?]"


function create_zdata_header() {
  # produce the minimum required header information
  temp="#Producer: ndw.12.4.5.1841\n"
  temp+="#AmdUUID: 564D1541-F5C0-9FBE-47B4-1D3C3417D6D4\n"
  temp+="#Fields: type=L amdIp:txt linkType:int localId:int linkName:txt linkVC:txt\n"
  temp+="#Fields: type=U srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt appType:int linkId:int tenantId:txt anlzType:int recAnlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int\n"
  temp+="#Fields: type=D srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt appType:int linkId:int tenantId:txt anlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int sslAlertA:int sslAlertB:int sslAlertN:int hits:int discardedHits:int HTTPCliErrors:int HTTPSrvErrors:int HTTPUnauthErrors:int HTTPNotFoundErrors:int transportFailures:int minSlowTransT:int maxSlowTransT:int transactions:int slowTransactions:int transT:int srvDelay:int HTTPSrvT:int transSize:int transLen:int hitsTrans:int requestSize:int\n"
  temp+="#Fields: type=P srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt scriptName:txt appType:int linkId:int tenantId:txt os:txt hardware:txt browser:txt browserVer:txt path:txt opStatus:txt userDefParam1:txt userDefParam2:txt userDefParam3:txt userDefParam4:txt userDefParam5:txt userDefParam6:txt userDefParam7:txt anlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int cliRetr:int srvRetr:int cliTcpPackets:int srvTcpPackets:int cliRetrPC:int srvRetrPC:int cliRtt:int srvRtt:int rttMeasures:int closedClientWindows:int userSessions:int slowUserSessions:int hits:int discardedHits:int discardedAbortHits:int deadHits:int breakHits:int HTTPCliErrors:int HTTPSrvErrors:int HTTPUnauthErrors:int HTTPNotFoundErrors:int HTTP_4xx_b3:int HTTP_5xx_b1:int HTTP_5xx_b2:int sslFailures:int transportFailures:int appFailures:int minSlowTransT:int maxSlowTransT:int minSrvSlowPageThreshold:int maxSrvSlowPageThreshold:int minThroughputThr:int transactions:int slowTransactions:int slowSrvTransactions:int fdiServerT:int fdiIdleT:int fdiRx:int fdiReqSize:int fdiRespSize:int fdiLatency:int fdiNumElements:int fdiMultipleNetwork:int transT:int srvDelay:int idleTime:int netT:int HTTPSrvT:int requestT:int HTTPRedirT:int ADCD:int ADCDNum:int bucketT:int transSize:int tput:int tputNum:int transLen:int cliTput:int cliTputNum:int hitsTrans:int requestSize:int appmask:int httpApplErr1:int httpApplErr2:int httpApplErr3:int httpApplErr4:int httpApplErr5:int userMetric1Cnt:int userMetric1Val:int userMetric2Cnt:int userMetric2Val:int userMetric3Cnt:int userMetric3Val:int userMetric4Cnt:int userMetric4Val:int userMetric5Cnt:int userMetric5Val:int aborts:int shortAborts:int\n"
  temp+="#Fields: type=PO srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt scriptName:txt appType:int linkId:int tenantId:txt os:txt hardware:txt browser:txt browserVer:txt anlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int cliRetr:int srvRetr:int cliTcpPackets:int srvTcpPackets:int cliRetrPC:int srvRetrPC:int cliRtt:int srvRtt:int rttMeasures:int closedClientWindows:int userSessions:int slowUserSessions:int hits:int discardedHits:int discardedAbortHits:int deadHits:int breakHits:int HTTPCliErrors:int HTTPSrvErrors:int HTTPUnauthErrors:int HTTPNotFoundErrors:int HTTP_4xx_b3:int HTTP_5xx_b1:int HTTP_5xx_b2:int sslFailures:int transportFailures:int appFailures:int minSlowTransT:int maxSlowTransT:int minSrvSlowPageThreshold:int maxSrvSlowPageThreshold:int minThroughputThr:int transactions:int slowTransactions:int slowSrvTransactions:int fdiServerT:int fdiIdleT:int fdiRx:int fdiReqSize:int fdiRespSize:int fdiLatency:int fdiNumElements:int fdiMultipleNetwork:int transT:int srvDelay:int idleTime:int netT:int HTTPSrvT:int requestT:int HTTPRedirT:int ADCD:int ADCDNum:int bucketT:int transSize:int tput:int tputNum:int transLen:int cliTput:int cliTputNum:int hitsTrans:int requestSize:int appmask:int httpApplErr1:int httpApplErr2:int httpApplErr3:int httpApplErr4:int httpApplErr5:int userMetric1Cnt:int userMetric1Val:int userMetric2Cnt:int userMetric2Val:int userMetric3Cnt:int userMetric3Val:int userMetric4Cnt:int userMetric4Val:int userMetric5Cnt:int userMetric5Val:int aborts:int shortAborts:int\n"

  # required AMD interface info, used in most other records.
  temp+="L 1.1.1.1 604 0 LAN 1.1.1.1%20LAN%Generated%Data\n"

  echo $temp
  return 0
}
# TODO create_zdata_header test case
#echo -e $(create_zdata_header) [$?]


function create_ndata_header() {
  # produce the minimum required header information
  temp="#Producer: ndw.12.4.5.1841\n"
  temp+="#AmdUUID: 564D1541-F5C0-9FBE-47B4-1D3C3417D6D4\n"
  temp+="#Fields: type=C srvIP:ip cliIP:ip srvPort:int appName:txt linkId:int tenantId:txt anlzType:int srvMac:txt cliMac:txt extSrvIP:ip extCliIP:ip tunnelType:txt vni:int vlan1:int vlan2:int srvQos:int cliQos:int wholeCliBytes:int wholeSrvBytes:int cliPackets:int srvPackets:int\n"

  echo $temp
  return 0
}
# TODO create_ndata_header test case
#echo -e $(create_ndata_header) [$?]


function create_tcp_record() {
  # create a valid zdata 'P' and PO record, covers TCP protocols like SMB, databases, MSRPC.
  # 110 #Fields: type=P srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt scriptName:txt appType:int linkId:int tenantId:txt os:txt hardware:txt browser:txt browserVer:txt path:txt opStatus:txt userDefParam1:txt userDefParam2:txt userDefParam3:txt userDefParam4:txt userDefParam5:txt userDefParam6:txt userDefParam7:txt anlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int cliRetr:int srvRetr:int cliTcpPackets:int srvTcpPackets:int cliRetrPC:int srvRetrPC:int cliRtt:int srvRtt:int rttMeasures:int closedClientWindows:int userSessions:int slowUserSessions:int hits:int discardedHits:int discardedAbortHits:int deadHits:int breakHits:int HTTPCliErrors:int HTTPSrvErrors:int HTTPUnauthErrors:int HTTPNotFoundErrors:int HTTP_4xx_b3:int HTTP_5xx_b1:int HTTP_5xx_b2:int sslFailures:int transportFailures:int appFailures:int minSlowTransT:int maxSlowTransT:int minSrvSlowPageThreshold:int maxSrvSlowPageThreshold:int minThroughputThr:int transactions:int slowTransactions:int slowSrvTransactions:int fdiServerT:int fdiIdleT:int fdiRx:int fdiReqSize:int fdiRespSize:int fdiLatency:int fdiNumElements:int fdiMultipleNetwork:int transT:int srvDelay:int idleTime:int netT:int HTTPSrvT:int requestT:int HTTPRedirT:int ADCD:int ADCDNum:int bucketT:int transSize:int tput:int tputNum:int transLen:int cliTput:int cliTputNum:int hitsTrans:int requestSize:int appmask:int httpApplErr1:int httpApplErr2:int httpApplErr3:int httpApplErr4:int httpApplErr5:int userMetric1Cnt:int userMetric1Val:int userMetric2Cnt:int userMetric2Val:int userMetric3Cnt:int userMetric3Val:int userMetric4Cnt:int userMetric4Val:int userMetric5Cnt:int userMetric5Val:int aborts:int shortAborts:int
  # 101 #Fields: type=PO srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt scriptName:txt appType:int linkId:int tenantId:txt os:txt hardware:txt browser:txt browserVer:txt anlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int cliRetr:int srvRetr:int cliTcpPackets:int srvTcpPackets:int cliRetrPC:int srvRetrPC:int cliRtt:int srvRtt:int rttMeasures:int closedClientWindows:int userSessions:int slowUserSessions:int hits:int discardedHits:int discardedAbortHits:int deadHits:int breakHits:int HTTPCliErrors:int HTTPSrvErrors:int HTTPUnauthErrors:int HTTPNotFoundErrors:int HTTP_4xx_b3:int HTTP_5xx_b1:int HTTP_5xx_b2:int sslFailures:int transportFailures:int appFailures:int minSlowTransT:int maxSlowTransT:int minSrvSlowPageThreshold:int maxSrvSlowPageThreshold:int minThroughputThr:int transactions:int slowTransactions:int slowSrvTransactions:int fdiServerT:int fdiIdleT:int fdiRx:int fdiReqSize:int fdiRespSize:int fdiLatency:int fdiNumElements:int fdiMultipleNetwork:int transT:int srvDelay:int idleTime:int netT:int HTTPSrvT:int requestT:int HTTPRedirT:int ADCD:int ADCDNum:int bucketT:int transSize:int tput:int tputNum:int transLen:int cliTput:int cliTputNum:int hitsTrans:int requestSize:int appmask:int httpApplErr1:int httpApplErr2:int httpApplErr3:int httpApplErr4:int httpApplErr5:int userMetric1Cnt:int userMetric1Val:int userMetric2Cnt:int userMetric2Val:int userMetric3Cnt:int userMetric3Val:int userMetric4Cnt:int userMetric4Val:int userMetric5Cnt:int userMetric5Val:int aborts:int shortAborts:int
  ssnames="Oracle%20SQL,MS%20SQL/Sybase%20Server,SAP%20RFC,LDAP,MSRPC,SMB,Exchange%202010"
  ssports="1521,1433,3340,389,49155,445,135"
  atype="18,18,87,85,54,49,513"

  IFS="," read -ra sarr <<< "$ssnames"
  IFS="," read -ra sprt <<< "$ssports"
  IFS="," read -ra atyp <<< "$atype"
  acount=$((${#sarr[@]}))
  arand=$(randnum $acount)
  ssname="${sarr[$arand]}"
  srvport="${sprt[$arand]}"
  atype="${atyp[$arand]}"

  srvip=$(rand_pick_from_list $slist)
  cliip=$(rand_pick_from_list $clist)

  clibytes=$(randnum 10000)
  srvbytes=$(randnum 10000)
  clipkts=$(randnum 1000)
  srvpkts=$(randnum 1000)
  clirtt=$(randnum 100)
  srvrtt=$(randnum 10)
  rttcnt=$(randnum 1000)
  usess=$(randnum 100)
  

  temp="P $srvip $cliip $cliip - $srvport $ssname - 6 0 - - - - - - - - - - - - - - $atype $clibytes $srvbytes $clibytes $srvbytes $clipkts $srvpkts 0 0 $clipkts $srvpkts 0 0 $clirtt $srvrtt $rttcnt 0 $usess 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 80000 80000 - - 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
  #field count test
  IFS=' ' read -ra stemp <<< "$temp"
  #echo 1 ${#stemp[@]} >&2
  if [ ${#stemp[@]} -ne 110 ]; then return 1; break; fi

  echo -n "$temp"
  echo -n "\n"

  temp="PO $srvip $cliip $cliip - $srvport $ssname - 6 0 - - - - - $atype $clibytes $srvbytes $clibytes $srvbytes $clipkts $srvpkts 0 0 $clipkts $srvpkts 0 0 $clirtt $srvrtt $rttcnt 0 $usess 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 80000 80000 - - 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
  #field count test
  IFS=' ' read -ra stemp <<< "$temp"
  #echo 2 ${#stemp[@]} >&2
  if [ ${#stemp[@]} -ne 101 ]; then return 1; break; fi

  echo $temp
  return 0
}
# TODO create_tcp_record: function test
#for ((i=0;i<10;i++)); do
#  echo -e $(create_tcp_record) [$?]
#done


function create_dns_record() {
  # create a valid zdata 'D' record (DNS)
  # #Fields: type=D srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt appType:int linkId:int tenantId:txt anlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int sslAlertA:int sslAlertB:int sslAlertN:int hits:int discardedHits:int HTTPCliErrors:int HTTPSrvErrors:int HTTPUnauthErrors:int HTTPNotFoundErrors:int transportFailures:int minSlowTransT:int maxSlowTransT:int transactions:int slowTransactions:int transT:int srvDelay:int HTTPSrvT:int transSize:int transLen:int hitsTrans:int requestSize:int

  srvip=$(rand_pick_from_list $slist)
  cliip=$(rand_pick_from_list $clist)

  temp="D $srvip $cliip $cliip - 53 Domain%20Name%20Server%20[U] 17 0 - 8 $(randnum 1000) $(randnum 1000) $(randnum 100) $(randnum 100) $(randnum 100) $(randnum 100) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"

  #field count test
  IFS=' ' read -ra stemp <<< "$temp"
  if [ ${#stemp[@]} -ne 38 ]; then return 1; break; fi

  echo "$temp"
  return 0
}
# TODO create_dns_record: function test
#for ((i=0;i<10;i++)); do
#  echo -e $(create_dns_record) [$?]
#done


function create_udp_record() {
  # create a valid zdata 'U' record (UDP/ICMP traffic)
  # #Fields: type=U srvIP:ip cliIP:ip inCliIP:ip cliName:txt srvPort:int appName:txt appType:int linkId:int tenantId:txt anlzType:int recAnlzType:int cliBytes:long srvBytes:long wholeCliBytes:long wholeSrvBytes:long cliPackets:int srvPackets:int
  # U 192.168.93.255 192.168.93.1 192.168.93.1 - 137 NetBIOS%20Name%20Service%20[U] 17 0 - 32772 4 300 0 552 0 6 0
  ssnames="SNMP%20[U],NetBIOS%20%Name%20Service%20[U],Other%20UDP%20Proto,Domain%20Name%20Service%20[U],NTP%20[U]"
  srvports="161,137,0,53,123"

  IFS="," read -ra sarr <<< "$ssnames"
  IFS="," read -ra sprt <<< "$srvports"
  acount=$((${#sarr[@]}))
  arand=$(randnum $acount)
  ssname="${sarr[$arand]}"
  srvport="${sprt[$arand]}"

  srvip=$(rand_pick_from_list $slist)
  cliip=$(rand_pick_from_list $clist)

  temp="U $srvip $cliip $cliip - $srvport $ssname 17 0 - 4 4 $(randnum 1000) $(randnum 1000) $(randnum 100) $(randnum 100) $(randnum 100) $(randnum 100)"

  #field count test
  IFS=' ' read -ra stemp <<< "$temp"
  if [ ${#stemp[@]} -ne 18 ]; then return 1; break; fi

  echo "$temp"
  return 0
}
# TODO create_udp_record: function test
#for ((i=0;i<10;i++)); do
#  echo -e $(create_udp_record) [$?]
#done


function create_ndata_record() {
  # create valid ndata 'C' records (layer 2 traffic)
  # #Fields: type=C srvIP:ip cliIP:ip srvPort:int appName:txt linkId:int tenantId:txt anlzType:int srvMac:txt cliMac:txt extSrvIP:ip extCliIP:ip tunnelType:txt vni:int vlan1:int vlan2:int srvQos:int cliQos:int wholeCliBytes:int wholeSrvBytes:int cliPackets:int srvPackets:int

  ssnames="Oracle%20SQL,MS%20SQL/Sybase%20Server,SAP%20RFC,LDAP,MSRPC,SMB,Exchange%202010,SNMP%20[U],NTP%20[U],HTTP,HTTPS,Domain%20Name%20Service%20[U],ICMP,Other%20TCP%20Proto,Kerberos,Other%20IP%20Proto,SMTP"
  ssports="1521,1433,3340,389,49155,445,135,161,123,80,443,53,0,0,88,0,25"
  atype="6,6,6,6,6,6,6,17,17,6,6,17,1,6,6,2,6"
  antype="4,4,87,85,54,49,4,65,0,4,4,8,16,0,50,16,27"

  IFS="," read -ra sarr <<< "$ssnames"
  IFS="," read -ra sprt <<< "$ssports"
  IFS="," read -ra atyp <<< "$atype"
  IFS="," read -ra antyp <<< "$antype"
  acount=$((${#sarr[@]}))
  arand=$(randnum $acount)
  ssname="${sarr[$arand]}"
  srvport="${sprt[$arand]}"
  atype="${atyp[$arand]}"
  antype="${antyp[$arand]}"

  srvip=$(rand_pick_from_list $slist)
  cliip=$(rand_pick_from_list $clist)
  smac=$(rand_pick_from_list $smaclist)
  cmac=$(rand_pick_from_list $cmaclist)

  temp="C $srvip $cliip $srvport $ssname $atype 0 - $antype $smac $cmac $srvip $cliip - - 1 1 0 0 $(randnum 10000) $(randnum 10000) $(randnum 1000) $(randnum 1000)"

  #field count test
  IFS=' ' read -ra stemp <<< "$temp"
  if [ ${#stemp[@]} -ne 23 ]; then return 1; break; fi

  echo "$temp"
  return 0
}
# TODO create_ndata_record: function test
#for ((i=0;i<50;i++)); do
#  echo -e $(create_ndata_record) [$?]
#done

#TODO create http record HL HLO h he?



function create_sample_files() {
  # produce sample files of random data using the passed time stamps $1

  IFS=',' read -ra tsarray <<< "$1"
  for filets in ${tsarray[@]}; do
    zdata="zdata_$(ts_to_hex ${filets})_${INTERVAL}_t"
    ndata="ndata_$(ts_to_hex ${filets})_${INTERVAL}_t"
    echo "Creating sample files: $zdata,$ndata"
    echo -e $(create_zdata_header) > $zdata
    for ((i=0;i<$RECORDS;i++)); do
      echo -e $(create_udp_record) >> $zdata
      echo -e $(create_dns_record) >> $zdata
      echo -e $(create_tcp_record) >> $zdata
    done

    echo -e $(create_ndata_header) > $ndata
    for ((i=0;i<$RECORDS;i++)); do
      echo -e $(create_ndata_record) >> $ndata
    done
    
  done

}

create_sample_files $(create_timestamps $INTERVAL $DURATION)



