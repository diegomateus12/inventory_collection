########################### Script to collect the information from the server and send it back to I2000 ###########################

########---BEGIN---########

#PLEASE SET THE I2000 IP ADDRESS
I2000="10.80.250.82";

#File to be sent
Host=$( hostname ); 
touch Inventory_$Host.csv;
chmod 777 Inventory_$Host.csv;

#Temp Files
touch Hostname;
chmod 777 Hostname;
touch dmidecode_output;
chmod 777 dmidecode_output;
touch memory;
chmod 777 memory;
touch IPaddr;
chmod 777 IPaddr;
touch suse;
chmod 777 suse;
touch database;
chmod 777 database;
touch dmi_temp;
chmod 777 dmi_temp;
touch dmi_temp2;
chmod 777 dmi_temp2;
touch Hostname2;
chmod 777 Hostname2;

#Hostname
hostname > Hostname;
awk '{
printf("%s %s\n","Hostname",$1);
}' Hostname > Hostname2;
#Dmidecode
sudo /usr/sbin/dmidecode > dmidecode_output;
#RAM Memory
cat /proc/meminfo > memory;
#Bond0 IP and MAC Address
ifconfig bond0 > IPaddr; 
#OS Version
cat /etc/SuSE-release > suse;
#DB version
#Check whether the server have oracle user or not
sudo cat /etc/shadow | grep oracle > database
if [ -s "database"  ];then
	su - oracle -c 'cat $ORACLE_HOME/bin/CompEMdbconsole.pm' | grep Release > database;
fi

#Information Organization to retrieve the line

#Hostname
awk '{
if($1~/Hostname/)
{printf("%s,",$2);}
}' Hostname2 > Inventory_$Host.csv;

#Blade_type
awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
if($2~/Board/)
{printf("%s",$4);}
}' dmidecode_output > dmi_temp;

awk '{
printf("%s,",$3);
}' dmi_temp >> Inventory_$Host.csv;

#Blade_version
awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
if($2~/Board/)
{printf("%s",$5);}
}' dmidecode_output > dmi_temp;

awk '{
printf("%s,",$2);
}' dmi_temp >> Inventory_$Host.csv;

#BIOS_vendor
awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
if($2~/BIOS Information/)
{printf("%s",$3);}
}' dmidecode_output > dmi_temp;

awk '{
printf("%s %s %s,",$2,$3,$4);
}' dmi_temp >> Inventory_$Host.csv;

#BIOS_version
awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
if($2~/BIOS Information/)
{printf("%s",$4);}
}' dmidecode_output > dmi_temp;

awk '{
printf("%s,",$2);
}' dmi_temp >> Inventory_$Host.csv;

#CPU1_version
awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
if($3~/CPU 1/)
{printf("%s",$38);}
}' dmidecode_output > dmi_temp;

awk '{
printf("%s %s %s %s %s %s,",$2,$3,$4,$5,$6,$7);
}' dmi_temp >> Inventory_$Host.csv;

#CPU2_version

#awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
#if($3~/CPU 2/)
#{printf("%s",$38);}
#}' dmidecode_output > dmi_temp;

#awk '{
#printf("%s %s %s %s %s %s,",$2,$3,$4,$5,$6,$7);
#}' dmi_temp >> Inventory_$Host.csv;

#RAM_memory
awk '{
if($1~/^MemTotal:/)
{printf("%s %s,",$2,$3);}
}' memory >> Inventory_$Host.csv;

#ROM_memory
awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
if($2~/Physical Memory Array/)
{printf("%s",$6);}
}' dmidecode_output > dmi_temp;

awk '{
printf("%s %s,",$3,$4);
}' dmi_temp >> Inventory_$Host.csv;

#IP_addrs
awk 'BEGIN{FS="\n";RS=""; OFS=","}{
printf("%s",$2);
}' IPaddr > dmi_temp;

awk '{
printf("%s",$2);
}' dmi_temp > dmi_temp2;

awk 'BEGIN{FS=":"}{
printf("%s,",$2);
}' dmi_temp2 >> Inventory_$Host.csv;

#MAC_addrs
awk 'BEGIN{FS="\n";RS=""; OFS=","}{
printf("%s",$1);
}' IPaddr > dmi_temp;

awk '{
printf("%s,",$5);
}' dmi_temp >> Inventory_$Host.csv;


#Serial Number
awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
if($2~/System/)
{printf("%s",$6);}
}' dmidecode_output > dmi_temp;

awk '{
printf("%s,",$3);
}' dmi_temp >> Inventory_$Host.csv;

#Manufacturer
awk 'BEGIN{FS="\n"; RS=""; OFS=","}{
if($2~/System/)
{printf("%s",$3);}
}' dmidecode_output > dmi_temp;

awk '{
printf("%s %s,",$2,$3);
}' dmi_temp >> Inventory_$Host.csv;

#Check whether the server have oracle user or not

if [ -s "database"  ];then

	#SuSE_Version
	awk '{
	if($1~/SUSE/)
	{printf("%s %s %s %s %s %s,",$1,$2,$3,$4,$5,$6);}
	}' suse >> Inventory_$Host.csv;

	#DB_version
	awk '{
	printf("Oracle %s %s %s %s %s %s\n",$3,$4,$5,$6,$8,$9);
	}' database >> Inventory_$Host.csv;

else
	
	#SuSE_Version
        awk '{
        if($1~/SUSE/)
        {printf("%s %s %s %s %s %s,\n",$1,$2,$3,$4,$5,$6);}
        }' suse >> Inventory_$Host.csv;	

fi



#Send File to I2000
#remember, this step requires trust relationship between the I2000 and the servers

scp Inventory_$Host.csv sshusr@$I2000:/home/sshusr/inventory_collection/information_collected;

#Temp files removal

rm Inventory_$Host.csv;
rm Hostname;
rm Hostname2;
rm dmidecode_output;
rm memory;
rm IPaddr;
rm suse;
rm database;
rm dmi_temp;
rm dmi_temp2;

########---END---########
