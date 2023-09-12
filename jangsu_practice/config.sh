#!/usr/bin/env bash

declare -A dict
n=0

while read filename station channel ka evdate evtime ptime stime swave; do
	if [[ ${channel} == 'ELZ' ]]; then dict[${station}]=${channel}
	elif [[ ${channel} == 'HGZ' ]]; then dict[${station}]=${channel}
	elif [[ ${channel} == 'HHZ' ]]; then dict[${station}]=${channel}
	else pass; fi; done < data_dist100.txt

cat data_dist100.txt | awk '{ print length($2), $0; }' | sort -n | while read len filename station channel pwave evdate evtime ptime stime swave b; do
	for key in ${!dict[@]}; do value=${dict[${key}]}
		if [[ ${station} == ${key} && ${channel} == ${value} ]]; then
			date -d '$evdate' +%s
			echo $evdate
			#printf '%-4s%-4s%16s%12s%-4s\n' $station $pwave $mod_ptime $mod_stime $swave >> hypo2.phase
		else continue; fi; done; done
		

cat station.txt | awk '{ print length($2), $0; }' | sort -n | while read len ks station2 latitude longitude elevation; do
	for key in ${!dict[@]}; do value=${dict[${key}]}
		if [[ ${station2} == ${key} ]]; then
			int_lat=${latitude/.*}; int_lon=${longitude/.*}; elev=`echo $elevation | awk '{printf "%.0f\n", $0}'`
			lat=`echo $latitude-$int_lat | bc -l | awk '{printf "%.2f\n", $0 * 60}'`; lon=`echo $longitude-$int_lon | bc -l | awk '{printf "%.2f\n", $0 * 60}'`
			if [[ $lat =~ ^[0-9]\.[0-9][0-9] ]] ;then lat='0'$lat ;fi
			if [[ $lon =~ ^[0-9]\.[0-9][0-9] ]] ;then lon='0'$lon ;fi
			printf '%4s%2dN%s%4dE%s%5d\n' $station2 $int_lat $lat $int_lon $lon $elev >> station.sta
			printf '%4s*\n' $station2 >> station.sta
		else continue; fi; done; done