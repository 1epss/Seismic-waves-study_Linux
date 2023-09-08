#!/bin/bash

n=0
array=()
while read filename station pwave evdate evtime ptime stime swave
do
	array[${n}]=${station}
	n=${n}+1
done < test.txt
echo ${array[@]}

while read ks station2 lat lon
do
	for i in ${array[@]}
	do
		if [[ ${station2} == ${i} ]]
		then
			echo ${station2}
			#위도 경도 계산
			#해발고도 ?
		else
			continue
		fi
	done

done < station.txt
