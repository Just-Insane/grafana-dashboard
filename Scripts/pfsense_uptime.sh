#!/bin/sh

sleeptime=30

while :
do

        sleep "$sleeptime"

        uptime=`snmpget -v2c -c public 192.168.1.1 .1.3.6.1.2.1.25.1.1.0 -Ov`

	#Cut out only that part of the returned information that we need
        uptime=$(echo $uptime | cut -f 2 -d '(')
        uptime=$(echo $uptime | cut -f 1 -d ')')

        uptime=$(($uptime /100))

echo $uptime

        curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "systemuptime,host=pfsense value=$uptime"
        
done