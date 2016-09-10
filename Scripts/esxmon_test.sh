
#!/bin/sh

#This script gets the current memory and CPU usage for the
#main ESXi server.  It's hacky at best but it works.

#The time we are going to sleep between readings
sleeptime=30
corecount=$(sshpass -p esxipass ssh -t root@esxiip "grep -c ^processor /proc/cpuinfo" 2> /dev/null)
corecount=$(echo $corecount | sed 's/\r$//')
#Prepare to start the loop and warn the user
#echo "Press [CTRL+C] to stop..."
#while :
#do
        CPUs=()
        for i in `seq 1 $corecount`;
        do
                CPUs[$i]="$(snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad."$i" -Ov)"
                CPUs[$i]="$(echo "$CPUs[$i]" | cut -c 10-)"
                echo $CPUs[$i]
        done

#        cpu1=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.1 -Ov`
 #       cpu2=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.2 -Ov`
  #      cpu3=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.3 -Ov`
   #     cpu4=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.4 -Ov`
    #    cpu5=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.5 -Ov`
     #   cpu6=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.6 -Ov`

       # cpu8=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.8 -Ov`
       # cpu9=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.9 -Ov`
       # cpu10=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.10 -Ov`
       # cpu11=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.11 -Ov`
       # cpu12=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.12 -Ov`
       # cpu13=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.13 -Ov`
       # cpu14=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.14 -Ov`
       # cpu15=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.15 -Ov`
       # cpu16=`snmpget -v 2c -c public 192.168.1.24 HOST-RESOURCES-MIB::hrProcessorLoad.16 -Ov`


        #Strip out the value from the SNMP query
       # cpu1=$(echo $cpu1 | cut -c 10-)
       # cpu2=$(echo $cpu2 | cut -c 10-)
       # cpu3=$(echo $cpu3 | cut -c 10-)
       # cpu4=$(echo $cpu4 | cut -c 10-)
       # cpu5=$(echo $cpu5 | cut -c 10-)
       # cpu6=$(echo $cpu6 | cut -c 10-)
       # cpu7=$(echo $cpu7 | cut -c 10-)
       # cpu8=$(echo $cpu8 | cut -c 10-)
       # cpu9=$(echo $cpu9 | cut -c 10-)
       # cpu10=$(echo $cpu10 | cut -c 10-)
       # cpu11=$(echo $cpu11 | cut -c 10-)
       # cpu12=$(echo $cpu12 | cut -c 10-)
       # cpu13=$(echo $cpu13 | cut -c 10-)
       # cpu14=$(echo $cpu14 | cut -c 10-)
       # cpu15=$(echo $cpu15 | cut -c 10-)
       # cpu16=$(echo $cpu16 | cut -c 10-)


        #Now lets get the hardware info from the remote host
        hwinfo=$(ssh -t root@192.168.1.24 "esxcfg-info --hardware")

        #Lets try to find the lines we are looking for
        while read -r line; do
                #Check if we have the line we are looking for
                if [[ $line == *"Kernel Memory"* ]]
                then
                  kmemline=$line
                fi
                if [[ $line == *"-Free."* ]]
                then
                  freememline=$line
                fi
                #echo "... $line ..."
        done <<< "$hwinfo"

        #Remove the long string of .s
        kmemline=$(echo $kmemline | tr -s '[.]')
        freememline=$(echo $freememline | tr -s '[.]')

        #Lets parse out the memory values from the strings
        #First split on the only remaining . in the strings
        IFS='.' read -ra kmemarr <<< "$kmemline"
        kmem=${kmemarr[1]}
        IFS='.' read -ra freememarr <<< "$freememline"
        freemem=${freememarr[1]}
        #Now break it apart on the space
        IFS=' ' read -ra kmemarr <<< "$kmem"
        kmem=${kmemarr[0]}
        IFS=' ' read -ra freememarr <<< "$freemem"
        freemem=${freememarr[0]}

        #Now we can finally calculate used percentage
        used=$((kmem - freemem))
        used=$((used * 100))
        pcent=$((used / kmem))

       # echo "CPU1: $cpu1%"
       # echo "CPU2: $cpu2%"
       # echo "CPU3: $cpu3%"
       # echo "CPU4: $cpu4%"
        echo "Memory Used: $pcent%"

        #Write the data to the database
       # curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=1 value=$cpu1"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=2 value=$cpu2"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=3 value=$cpu3"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=4 value=$cpu4"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=5 value=$cpu5"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=6 value=$cpu6"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=7 value=$cpu7"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=8 value=$cpu8"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=9 value=$cpu9"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=10 value=$cpu10"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=11 value=$cpu11"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=12 value=$cpu12"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=13 value=$cpu13"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=14 value=$cpu14"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=15 value=$cpu15"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=cpu_usage,cpu_number=16 value=$cpu16"
        #curl -i -XPOST 'http://localhost:8086/write?db=home' --data-binary "esxi_stats,host=esxi1,type=memory_usage value=$pcent"

        #Wait for a bit before checking again
#        sleep "$sleeptime"

#done

