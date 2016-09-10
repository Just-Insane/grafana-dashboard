#!/bin/sh

sleeptime=30

while :
do

        sleep "$sleeptime"

        uptime=`snmpget -v2c -c public 192.168.1.5 .1.3.6.1.2.1.25.1.1.0 -Ov`

	#Cut the returned string down to the correct length
        uptime=$(echo $uptime | cut -f 2 -d '(')
        uptime=$(echo $uptime | cut -f 1 -d ')')


        uptime=$(($uptime /100))

echo $uptime

        curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "systemuptime,host=freenas value=$uptime"

done