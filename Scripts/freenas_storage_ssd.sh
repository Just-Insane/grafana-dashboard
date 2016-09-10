#!/bin/sh
#For SSD pool
discriptionSSD="VMware-Storage"
#For HDD pool
discriptionHDD="ESXI-Datastore"
sleeptime=10

#Ensure that you are still tracking the correct storage (could change after reboot)
storagedescSSD=`snmpget -v2c -c public 192.168.1.5 HOST-RESOURCES-MIB::hrStorageDescr.55`
storagedescSSD=$(echo $storagedescSSD | cut -f 4 -d '/')

echo
echo $discriptionSSD
echo $storagedescSSD


if [ "$discriptionSSD" != "$storagedescSSD" ]; then
	echo Error
else

	while :
	do

	        sleep "$sleeptime"
	
		#Getting the size of my VM SSD Pool (signified by the .54 at the end of the snmp query)
    	    totalsizeSSD=`snmpget -v2c -c public 192.168.1.5 HOST-RESOURCES-MIB::hrStorageSize.55`
    	    usedSSD=`snmpget -v2c -c public 192.168.1.5 HOST-RESOURCES-MIB::hrStorageUsed.55`
        
		#Cut the returned string down to the correct length
        	totalsizeSSD=$(echo $totalsizeSSD | cut -c 49-)
        	usedSSD=$(echo $usedSSD | cut -c 49-)
        	
        	echo $totalsizeSSD
        	echo $usedSSD
        	
        #Multiply by the AllocationUnits (HOST-RESOURCES-MIB::hrStorageAllocationUnits.55)
        	totalsizeSSD=$(( 512 * $totalsizeSSD ))
        	usedSSD=$(( 512 * $usedSSD ))
        
        	echo $totalsizeSSD
        	echo $usedSSD
        
    	#Calculate the amount of free storage
    		freeSSD=$(($totalsizeSSD - $usedSSD))

        	curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,field=total,type=SSD value=$totalsizeSSD"
			curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,field=used,type=SSD value=$usedSSD"
			curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,field=free,type=SSD value=$freeSSD"
	done
fi