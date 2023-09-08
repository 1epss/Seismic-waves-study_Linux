#!/bin/bash
 
#saclst kstnm ka kzdate kztime a t0 kt0 f *Z.sac

while read line
do

	echo $line
	evtime=`echo $line | cut -d ' ' -f 4-5 | sed 's/\//-/g'` 
	ptime=`echo $line | cut -d ' ' -f 6`
	stime=`echo $line | cut -d ' ' -f 7`
	station=`echo $line | cut -d ' ' -f 2`
	pwave=`echo $line | cut -d ' ' -f 3`
	swave=`echo $line | cut -d ' ' -f 8`

	evntime=`date -d"$evtime" "+%s.%N"`
	evpntime=`date -d"$evtime + $ptime second" "+%s.%N"`
	evsntime=`date -d"$evtime + $stime second" "+%s.%N"`	

	ev1time=`date -d "@$evntime" "+%y%m%d%H%M%S.%2N"`
	ev1ptime=`date -d "@$evpntime" "+%y%m%d%H%M%S.%2N"`
	ev1stime=`date -d "@$evsntime" "+%S.%2N"`

	if [[ `echo "${#station}"` == 3 ]]
	then
	echo "$station $pwave $ev1ptime       $ev1stime$swave" >> hypo.phase
	else
	echo "$station$pwave $ev1ptime       $ev1stime$swave" >> hypo.phase
	fi

	# if 문 중간에 $swave 60 넘을시 그대로 출력하게 하는 조건문 넣어야함
	
done < test.txt
