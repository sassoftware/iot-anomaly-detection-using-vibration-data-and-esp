#!/bin/bash

# Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  
# All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

BASE=$PWD
FILEBASE="/usr/local/adlink"
LIST=('1902' '1903' '1901' '2401' '2405' '7230' '7250' '1210')

ModifyConf()
{
	cd $BASE/util
	./usbdask_conf_deb
	sudo perl ud_debian.pl
}


ResetDef()
{
	echo -e "Restore conf files..."
	sudo cp $FILEBASE/ud-dask/conf/default/*.conf /etc/modprobe.d/
	test -z $(ls /etc/modprobe.d/*.conf | tail -1) && echo ">>>>> Fail <<<<<" || echo ">>>>> Success <<<<<"
	sudo depmod -a
	
	echo -e "Restore conf table..."
	if [ -e "$BASE/util/usbdask.conf" ]
	then
		sudo rm $BASE/util/usbdask.conf
	fi
	sudo cp $FILEBASE/ud-dask/conf/default/usbdask.conf $BASE/util/
	sudo chmod 755 $BASE/util/usbdask.conf
	sudo chown $USER $BASE/util/usbdask.conf
	sudo chgrp $USER $BASE/util/usbdask.conf
	test -e $BASE/util/usbdask.conf && echo ">>>>> Success <<<<<" || echo ">>>>> Fail <<<<<"
	echo -e "\nDependency setting finished.\n"
}


MoveConf()
{
	for element in "${LIST[@]}"
	do
	if [ -e "/etc/modprobe.d/u$element.conf" ]
	then 
		sudo rm "/etc/modprobe.d/u$element.conf"
	fi
	done
	sudo mv $BASE/conf/user/*.conf /etc/modprobe.d/
	echo -e "Move Config file..."	
}


Display()
{
	echo -e "Cards is inserted now:"
	echo -e "================================================================="
	echo -e "Card\tAI\tAO\tDI\tDO\t[unit: KB]"
	flag=1
	index=0
	for element in "${LIST[@]}"
	do
		for ((i=0;i<9;i++))
		do
		    if [ -e "/dev/u"$element"W0"$i ]
		    then
			flag=0
			#cat /etc/modprobe.d/u$element.conf
			FILE=/etc/modprobe.d/u$element.conf
			while read line; do
				newline="$(echo $line | sed -e 's/options //g ;  s/BufSize=//g ; s/,/ /g')"
				OIFS="$IFS"
				IFS=' '
				read -a new_string <<< $newline
				IFS="$OIFS"
			done < $FILE
			echo -e "${new_string[0]}\t${new_string[1]}\t${new_string[2]}\t${new_string[3]}\t${new_string[4]}"
			break
		    fi
		done
		((index++))
	done
	if [ $flag -eq 1 ]
	then
		echo -e "No card inserted."
	fi
	echo -e "=================================================================\n"
}



Reboot()
{
	#Reboot
	echo -e ">>>>> SYSTEM REBOOT REQUIRED <<<<<\n"
	echo -e "Do you want to reboot now? (Y/N)"
	read REBOOT
	if [[ $REBOOT == "y" || $REBOOT == "Y" ]]; then
		reboot
		#echo "reboot"
	else
		echo "Please reboot later by youself"
	fi
}

#-----------------------------------------------------------------------------------------------------------------

echo -e "Reset config setting procedure...\n"
Display

#Flow choice
echo -e "Please choose the flow:"
while :
do
echo -e "(1) Change to User settings (2) Restore original factory settings"
read FLOW
case "$FLOW" in
	1)
	echo -e "Modify...\n"
	ModifyConf
	MoveConf
	break
	;;
	2)
	echo -e "Restore config...\n"
	ResetDef
	break
	;;
	*)
	echo "Wrong input"
	;;
esac
done
Reboot

