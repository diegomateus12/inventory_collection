#################### Script to request the information to the servers included in the list and create the Final Inventory ####################
######## BEGIN #########

cur_dir=$( pwd );
info_dir=$cur_dir/information_collected/;
final_inv_dir=$cur_dir/Final_Inventory;

# Information Collector function
remote_execute()
{
        remote_ip=$1
	
	#Send the collector script to the server and execute it
	#remember, these steps require trust relationship between the I2000 and the servers
        ssh sshusr@$remote_ip "mkdir -p /tmp/inv_collec"
        scp $cur_dir/server_collector.sh sshusr@$remote_ip:/tmp/inv_collec
        ssh sshusr@$remote_ip "cd /tmp/inv_collec; chmod +x server_collector.sh;./server_collector.sh"
}


main()
{
	#Check whether the server list exists
	if [ ! -f "$cur_dir/server_list" ];then
		echo "server_list file Not Found"
		exit 1
	fi
	
	#Check the server list and execute the collector script in each server of the list
	for i in $(cat $cur_dir/server_list)
	do
		remote_execute $i

		if [ $? -ne 0 ];then
			echo "[Error] Remote Execution Failed in Server: $i"
		fi
	done
	
	#Create the Final Inventory File
	cd $info_dir;
	files_rcv=$info_dir/*
	tm=$( date "+%Y-%m-%d" );
	touch $final_inv_dir/Final_Inventory_$tm.csv
	chmod 777 $final_inv_dir/Final_Inventory_$tm.csv
	echo "Hostname,Blade_Type,Blade_Version,BIOS_Vendor,BIOS_Version,CPU1_Version,RAM_Memory,ROM_Memory,IP_address,MAC_address,Serial,Manufacturer,SuSE_Version,DB_Version" > $final_inv_dir/Final_Inventory_$tm.csv
	for f in $files_rcv
	do
		awk '{
		printf("%s\n",$0);
		}' $f >> $final_inv_dir/Final_Inventory_$tm.csv; 
	done
	echo ""
	echo "________________________________________________________________________________________________________________"
	echo ""
	echo "The Final Inventory: $final_inv_dir/Final_Inventory_$tm.csv";
	echo "________________________________________________________________________________________________________________"
	echo ""
}
main $@

######## END ########
