#!/bin/sh

#The time we are going to sleep between readings
sleeptime=30

#Prepare to start the loop and warn the user
echo "Press [CRRL+C] to stop..."
while :
do

#       uptime=`snmpget -v 2c -c public 192.168.1.16 SNMPv2-MIB::sysUpTime.0 -Ov`

#       uptime=$(echo $uptime | cut -c 12-)

                uptime=`snmpget -v 2c -c public 192.168.1.16 SNMPv2-MIB::sysUpTime.0 -Ov`

			#Cut out the part of the returned information that we need
				uptime=$(echo $uptime | cut -f 2 -d '(')
        		uptime=$(echo $uptime | cut -f 1 -d ')')

                uptime=$(($uptime / 100))

        #Write the data to the database
        curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "systemuptime,host=edgeswitch,measurement=date value=$uptime"

        sleep "$sleeptime"

done