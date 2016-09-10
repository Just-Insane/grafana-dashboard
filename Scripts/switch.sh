#!/bin/sh

#The time we are going to sleep between readings
#Also used to calculate the current usage on the interface
#30 seconds seems to be ideal, any more frequent and the data
#gets really spikey.  Since we are calculating on total octets
#you will never loose data by setting this to a larger value.
sleeptime=30

#We need to get a baseline for the traffic before starting the loop
#otherwise we have nothing to base out calculations on.

#Get in and out octets
oldin1=`snmpget -v 2c -c public 192.168.1.16 IF-MIB::ifInOctets.1 -Ov`
oldout1=`snmpget -v 2c -c public 192.168.1.16 IF-MIB::ifOutOctets.1 -Ov`

#Strip out the value from the string
oldin1=$(echo $oldin1 | cut -c 12-)
oldout1=$(echo $oldout1 | cut -c 12-)

#Prepare to start the loop and warn the user
echo "Press [CTRL+C] to stop..."
while :
do
        #We need to wait between readings to have somthing to compare to
        sleep "$sleeptime"

        #Get in and out octets
        in1=`snmpget -v 2c -c public 192.168.1.16 IF-MIB::ifInOctets.1 -Ov`
        out1=`snmpget -v 2c -c public 192.168.1.16 IF-MIB::ifOutOctets.1 -Ov`

        #Strip out the value from the string
        in1=$(echo $in1 | cut -c 12-)
        out1=$(echo $out1 | cut -c 12-)

        #Get the difference between the old and current
        diffin1=$((in1 - oldin1))
        diffout1=$((out1 - oldout1))

        #Calculate the bytes-per-second
        inbps1=$((diffin1 / sleeptime))
        outbps1=$((diffout1 / sleeptime))

        #Seems we need some basic data validation - can't have values less than 0!
        if [[ $inbps1 -lt 0 || $outbps1 -lt 0 ]]
        then
                #There is an issue with one or more readings, get fresh ones
                #then wait for the next loop to calculate again.
                echo "We have a problem...moving to plan B"

                #Get in and out octets
                oldin1=`snmpget -v 2c -c public 192.168.1.16 IF-MIB::ifInOctets.1 -Ov`
                oldout1=`snmpget -v 2c -c public 192.168.1.16 IF-MIB::ifOutOctets.1 -Ov`

                #Strip out the value from the string
                oldin1=$(echo $oldin1 | cut -c 12-)
                oldout1=$(echo $oldout1 | cut -c 12-)
        else
                #Output the current traffic
                echo "Port 1 Inbound Traffic: $inbps1 Bps"

                #Write the data to the database
                curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "network_traffic,host=edgeswitch,interface=gig1,direction=inbound value=$inbps1"
                curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "network_traffic,host=edgeswitch,interface=gig1,direction=outbound value=$outbps1"

                #Move the current variables to the old ones
                oldin1=$in1
                oldout1=$out1

        fi

done