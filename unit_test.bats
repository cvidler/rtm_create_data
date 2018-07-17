#!/usr/local/bin/bats
# BATS unit tests for rtm_create_data.sh


##
## rtm_create_data.sh tests
##

@test "rtm_create_data.sh: present" {
  [ -r ./rtm_create_data.sh ]
}

@test "rtm_create_data.sh: executable" {
  [ -x ./rtm_create_data.sh ]
}

@test "rtm_create_data.sh: help" {
  run ./rtm_create_data.sh -h
  echo -e "$output"
  [ $status -eq 1 ]
  [ "${lines[0]}" == "*** INFO: Usage: ./rtm_create_data.sh [-h] [-c count] [-s count] [-u count] [-r count] [-i interval] [-l length]" ] 
}

@test "rtm_create_data.sh: invalid parameter" {
  run ./rtm_create_data.sh -g
  [ $status -eq 1 ]
  len=${#lines[0]}
  result=${lines[0]:$len-31}
  [ "${result}" == "*** FATAL: Invalid argument -g." ]
}

##
## input validation/parameter bounds checking
##

@test "rtm_create_data.sh: interval parameter missing" {
  run ./rtm_create_data.sh -i
  [ $status -eq 1 ]
  [ "${lines[0]}" == "*** FATAL: argument -i requires parameter." ]
}

@test "rtm_create_data.sh: interval parameter out of bounds: 0" {
  run ./rtm_create_data.sh -i 0
  [ $status -eq 1 ]
  [ "${lines[0]}" == "0 invalid value, required 1 or 5. Default: 5" ]
}

@test "rtm_create_data.sh: interval parameter out of bounds: 2" {
  run ./rtm_create_data.sh -i 2
  [ $status -eq 1 ]
  [ "${lines[0]}" == "2 invalid value, required 1 or 5. Default: 5" ]
}

@test "rtm_create_data.sh: interval parameter out of bounds: 20" {
  run ./rtm_create_data.sh -i 20
  [ $status -eq 1 ]
  [ "${lines[0]}" == "20 invalid value, required 1 or 5. Default: 5" ]
}

@test "rtm_create_data.sh: interval parameter out of bounds: text" {
  run ./rtm_create_data.sh -i text
  [ $status -eq 1 ]
  [ "${lines[2]}" == "text invalid value, required 1 or 5. Default: 5" ]
}



@test "rtm_create_data.sh: length parameter missing" {
  run ./rtm_create_data.sh -l
  [ $status -eq 1 ]
  [ "${lines[0]}" == "*** FATAL: argument -l requires parameter." ]
}

@test "rtm_create_data.sh: length parameter out of bounds: 0" {
  run ./rtm_create_data.sh -l 0
  [ $status -eq 1 ]
  [ "${lines[0]}" == "0 invalid value for length, required 5-1440. Default: 60" ]
}

@test "rtm_create_data.sh: length parameter out of bounds: 2" {
  run ./rtm_create_data.sh -l 2
  [ $status -eq 1 ]
  [ "${lines[0]}" == "2 invalid value for length, required 5-1440. Default: 60" ]
}

@test "rtm_create_data.sh: length parameter out of bounds: 2000" {
  run ./rtm_create_data.sh -l 2000
  [ $status -eq 1 ]
  [ "${lines[0]}" == "2000 invalid value for length, required 5-1440. Default: 60" ]
}

@test "rtm_create_data.sh: length parameter out of bounds: text" {
  run ./rtm_create_data.sh -l text
  [ $status -eq 1 ]
  [ "${lines[1]}" == "text invalid value for length, required 5-1440. Default: 60" ]
}



@test "rtm_create_data.sh: clients parameter missing" {
  run ./rtm_create_data.sh -c
  [ $status -eq 1 ]
  [ "${lines[0]}" == "*** FATAL: argument -c requires parameter." ]
}

@test "rtm_create_data.sh: clients parameter out of bounds: 0" {
  run ./rtm_create_data.sh -c 0
  [ $status -eq 1 ]
  [ "${lines[0]}" == "0 invalid value for client count, required 1 to 32767. Default: 100" ]
}

@test "rtm_create_data.sh: clients parameter out of bounds: 32768" {
  run ./rtm_create_data.sh -c 32768
  [ $status -eq 1 ]
  [ "${lines[0]}" == "32768 invalid value for client count, required 1 to 32767. Default: 100" ]
}

@test "rtm_create_data.sh: clients parameter out of bounds: a" {
  run ./rtm_create_data.sh -c a
  [ $status -eq 1 ]
  [ "${lines[1]}" == "a invalid value for client count, required 1 to 32767. Default: 100" ]
}



@test "rtm_create_data.sh: servers parameter missing" {
  run ./rtm_create_data.sh -s
  [ $status -eq 1 ]
  [ "${lines[0]}" == "*** FATAL: argument -s requires parameter." ]
}

@test "rtm_create_data.sh: servers parameter out of bounds: 0" {
  run ./rtm_create_data.sh -s 0
  [ $status -eq 1 ]
  [ "${lines[0]}" == "0 invalid value for server count, required 1 to 32767. Default: 100" ]
}

@test "rtm_create_data.sh: servers parameter out of bounds: 32768" {
  run ./rtm_create_data.sh -s 32768
  [ $status -eq 1 ]
  [ "${lines[0]}" == "32768 invalid value for server count, required 1 to 32767. Default: 100" ]
}

@test "rtm_create_data.sh: servers parameter out of bounds: a" {
  run ./rtm_create_data.sh -s a
  [ $status -eq 1 ]
  [ "${lines[1]}" == "a invalid value for server count, required 1 to 32767. Default: 100" ]
}



@test "rtm_create_data.sh: URLs parameter missing" {
  run ./rtm_create_data.sh -u
  [ $status -eq 1 ]
  [ "${lines[0]}" == "*** FATAL: argument -u requires parameter." ]
}

@test "rtm_create_data.sh: URLs parameter out of bounds: 0" {
  run ./rtm_create_data.sh -u 0
  [ $status -eq 1 ]
  [ "${lines[0]}" == "0 invalid value for URL count, required 1 to 32767. Default: 100" ]
}

@test "rtm_create_data.sh: URLs parameter out of bounds: 32768" {
  run ./rtm_create_data.sh -u 32768
  [ $status -eq 1 ]
  [ "${lines[0]}" == "32768 invalid value for URL count, required 1 to 32767. Default: 100" ]
}

@test "rtm_create_data.sh: URLs parameter out of bounds: a" {
  run ./rtm_create_data.sh -u a
  [ $status -eq 1 ]
  [ "${lines[1]}" == "a invalid value for URL count, required 1 to 32767. Default: 100" ]
}



@test "rtm_create_data.sh: records parameter missing" {
  run ./rtm_create_data.sh -r
  [ $status -eq 1 ]
  [ "${lines[0]}" == "*** FATAL: argument -r requires parameter." ]
}

@test "rtm_create_data.sh: recordss parameter out of bounds: 0" {
  run ./rtm_create_data.sh -r 0
  [ $status -eq 1 ]
  [ "${lines[0]}" == "0 invalid value for record count, required 1 to 1000000. Default: 50" ]
}

@test "rtm_create_data.sh: records parameter out of bounds: 1000001" {
  run ./rtm_create_data.sh -r 1000001
  [ $status -eq 1 ]
  [ "${lines[0]}" == "1000001 invalid value for record count, required 1 to 1000000. Default: 50" ]
}

@test "rtm_create_data.sh: recordss parameter out of bounds: a" {
  run ./rtm_create_data.sh -r a
  [ $status -eq 1 ]
  [ "${lines[1]}" == "a invalid value for record count, required 1 to 1000000. Default: 50" ]
}









