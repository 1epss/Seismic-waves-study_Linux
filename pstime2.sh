#!/bin/bash
 
#saclst kstnm ka kzdate kztime a t0 kt0 f *Z.sac

while read filename station pwave evdate evtime ptime stime swave
do
	echo ${filename}
	event=`echo "${evdate} ${evtime}" | sed 's/\//-/g'` 

	evnatime=`date -d"${event}" "+%s.%N"`
	pnatime=`date -d"${event} + ${ptime} second" "+%s.%N"`
	snatime=`date -d"${event} + ${stime} second" "+%s.%N"`	

	mod_evtime=`date -d "@${evnatime}" "+%y%m%d%H%M%S.%2N"`
	mod_ptime=`date -d "@${pnatime}" "+%y%m%d%H%M%S.%2N"`
	mod_stime=`date -d "@${snatime}" "+%S.%2N"`

	if [[ `echo "${#station}"` == 3 ]]
	then
	echo "${station} ${pwave} ${mod_ptime}       ${mod_stime}${swave}" >> hypo2.phase
	else
	echo "${station}${pwave} ${mod_ptime}       ${mod_stime}${swave}" >> hypo2.phase
	fi
	
	# if 문 중간에 $swave 60 넘을시 그대로 출력하게 하는 조건문 넣어야함
	
done < test.txt
