#!/bin/sh

sleeptime=30

while :
do

        sleep "$sleeptime"

        cpu0=`snmpget -v2c -c public 192.168.1.5 .1.3.6.1.2.1.25.1.8 -Ov`
        cpu1=`snmpget -v2c -c public 192.168.1.5 .1.3.6.1.2.1.25.1.9 -Ov`
        cpu2=`snmpget -v2c -c public 192.168.1.5 .1.3.6.1.2.1.25.1.10 -Ov`
        cpu3=`snmpget -v2c -c public 192.168.1.5 .1.3.6.1.2.1.25.1.11 -Ov`

	#Cut the leading text up to the 3 digit number that is returned
        cpu0=$(echo $cpu0 | cut -c 10-)
        cpu1=$(echo $cpu1 | cut -c 10-)
        cpu2=$(echo $cpu2 | cut -c 10-)
        cpu3=$(echo $cpu3 | cut -c 10-)

	#Devide by 10 to make a 2 digit number that makes sense in the dashboard
        cpu0=$(( $cpu0 / 10 ))
        cpu1=$(( $cpu1 / 10 ))
        cpu2=$(( $cpu2 / 10 ))
        cpu3=$(( $cpu3 / 10 ))

        curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,cpu_number=0 value=$cpu0"
        curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,cpu_number=1 value=$cpu1"
        curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,cpu_number=2 value=$cpu2"
        curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,cpu_number=3 value=$cpu3"
done