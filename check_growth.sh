#!/bin/bash                             #
#Author: Gustavo Gomes Silva 			#
#Email: gustavo.gomes@t-systems.com.br  #
#Team: Storage                          #
#Company: T-Systems do Brasil			#
#Purpose: Verifiy if auto size has 		#
# 		  reached its limit	            #
#Date: 28/03/2019                       #
#Version: 1.0                           #
#########################################

for storage in `cat /home/gsilva10/scripts/check_grow/storages`;
do
	exists=`ssh $storage df -g | grep -i krtn | wc -l`
	if [ $exists -ne 0 ]; then
		echo $storage >> /home/gsilva10/scripts/check_grow/.trash/storages_inuse
	fi
done
for storages_inuse in `cat /home/gsilva10/scripts/check_grow/.trash/storages_inuse`; 
do
	ssh $storages_inuse df -g | grep -i krtn | grep -v snapshot | cut -d "/" -f3 >> /home/gsilva10/scripts/check_grow/.trash/volumes_$storages_inuse
done
for storage_now in `cat /home/gsilva10/scripts/check_grow/.trash/storages_inuse`;
do
	for volume in `cat /home/gsilva10/scripts/check_grow/.trash/volumes_$storage_now`;
	do
		grow=`ssh $storage_now vol status -v $volume | grep -i grep -i mode | cut -d "=" -f2 | wc -l`
		if [ $grow > 0 ]; then
			echo $volume >> /home/gsilva10/scripts/check_grow/.trash/$storage_now
		fi
	done
done
for storage_core in `cat /home/gsilva10/scripts/check_grow/.trash/storages_inuse`;
do
	for volumes_inuse in `cat /home/gsilva10/scripts/check_grow/.trash/$storage_core`;
	do
		volsize=`ssh $storage_core vol size $volumes_inuse | awk '{print $8}' | cut -d "." -f1 | cut -d "g" -f1`
		maxsize=`ssh $storage_core vol status -v $volumes_inuse | grep -i maximum-size | cut -d "=" -f2 | cut -d " " -f1`
		if [[ $volsize -eq $maxsize ]]; then
			echo "Error 1: Autosize: Volume auto size configuration in $volumes_inuse within storage $storage_core has reached it's limit! Please check."
		else
			echo 0
		fi
	done
done
