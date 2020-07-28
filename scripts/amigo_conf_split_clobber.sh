#!/bin/bash


# Requires 2 files to work
# amigo.yaml.blank should be the amigo.yaml file with all gaf files removed
# file_list is the generated file of all gaf files
#   that is generated with the following:
#   find /data/www/planteome_dev/amigo/associations/clobber -maxdepth 1 | sed 's/^/    - file:\/\//'

# find line number where GAF list is to start
line_number=`grep -n GOLR_GAF_LIST amigo.yaml.blank | awk -F ":" '{print $1}'`


# add 4 to get the actual line number to insert at
line_number=$(($line_number + 4))

base_filename="amigo.yaml.clobber_set."

mapfile -t file_array < file_list_clobber
array_size=${#file_array[@]}
file_counter=0

for ((i=0; i<array_size; i++))
do
	line_command="${line_number}i"
	file_counter=$(($file_counter + 1))
	filename=$(printf "$base_filename%02d" $file_counter)
	sed "$line_command/${file_array[$i]}" amigo.yaml.blank | sed 's/^\///' > $filename
done

