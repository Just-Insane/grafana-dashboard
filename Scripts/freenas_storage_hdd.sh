#!/bin/sh
#For HDD pool
discriptionHDD="ESXI-Datastore"
sleeptime=10

#Ensure that you are still tracking the correct storage (could change after reboot)
storagedescHDD=`snmpget -v2c -c public 192.168.1.5 HOST-RESOURCES-MIB::hrStorageDescr.40`
storagedescHDD=$(echo $storagedescHDD | cut -f 4 -d '/')

echo
echo $discriptionHDD
echo $storagedescHDD


if [ "$discriptionHDD" != "$storagedescHDD" ]; then
	echo Error
else

	while :
	do

	        sleep "$sleeptime"
	
		#Getting the size of my VM HDD Pool (signified by the .54 at the end of the snmp query)
    	    totalsizeHDD=`snmpget -v2c -c public 192.168.1.5 HOST-RESOURCES-MIB::hrStorageSize.40`
    	    usedHDD=`snmpget -v2c -c public 192.168.1.5 HOST-RESOURCES-MIB::hrStorageUsed.40`
        
		#Cut the returned string down to the correct length
        	totalsizeHDD=$(echo $totalsizeHDD | cut -c 49-)
        	usedHDD=$(echo $usedHDD | cut -c 49-)
        	
        	echo $totalsizeHDD
        	echo $usedHDD
        	
        #Multiply by the AllocationUnits (HOST-RESOURCES-MIB::hrStorageAllocationUnits.55)
        	totalsizeHDD=$(( 2048 * $totalsizeHDD ))
        	usedHDD=$(( 2048 * $usedHDD ))
        
        	echo $totalsizeHDD
        	echo $usedHDD
        
    	#Calculate the amount of free storage
    		freeHDD=$(($totalsizeHDD - $usedHDD))

        	curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,field=total,type=HDD value=$totalsizeHDD"
			curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,field=used,type=HDD value=$usedHDD"
			curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "storage,host=freenas,field=free,type=HDD value=$freeHDD"
	done
fi