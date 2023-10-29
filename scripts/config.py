import numpy as np
import pandas as pd
import obspy
from obspy.geodetics.flinnengdahl import FlinnEngdahl
import re
import os
import time
from selenium import webdriver as wd
from selenium.webdriver.common.by import By

def init(wavedata_direction):
    station = pd.read_csv('./station.txt', sep='\s{1,}', engine='python')
    station.columns=['NETWORK','STATION','LATITUDE','LONGITUDE','ELEVATION']
    file = os.listdir(wavedata_direction)
    array = list(filter(lambda x: re.match('.*Z.sac$', x), file))
    array.sort()
    array.sort(key=lambda x : len(x))
    dic = {}
    unit_array = []
    for i in array:
        sta, cha = i.split('.')[0], i.split('.')[2]
        if cha == 'ELZ':
            dic[sta] = cha
        elif cha == 'HGZ':
            dic[sta] = cha
        elif cha == 'HHZ' :
            dic[sta] = cha
        else :
            pass    
    for key, value in dic.items():    
        unit = '{0}.KS.{1}.sac'.format(key, value)
        unit_array.append(unit)
    return station, unit_array

def make_hypo(filename, wavedata_direction):
    station, unit_array = init(wavedata_direction)
    with open(filename, 'a') as f:
        for i in unit_array:
            st = obspy.read(wavedata_direction + i)
            # 터미널에서 saclst로 필요한 데이터 가져오는 코드와 동일
            # saclst와 다르게 month & day가 아닌 julday로 반환하는 것 주의
            tnm, ka, year, jday, hour, minute, sec, msec, a, t0, kt0 = st[0].stats.sac.kstnm, st[0].stats.sac.ka, st[0].stats.sac.nzyear, st[0].stats.sac.nzjday, st[0].stats.sac.nzhour, st[0].stats.sac.nzmin, st[0].stats.sac.nzsec, st[0].stats.sac.nzmsec, st[0].stats.sac.a, st[0].stats.sac.t0, st[0].stats.sac.kt0
            # HHZ > HGZ > ELZ 순의 우선순위 적용
            # 정확한 시간 계산 위해 obspy.UTCDateTime.timestamp로 nanoseconds 형식의 P파 도달시간, S파 도달시간, PS시 추출
            # 정확한 계산 위해 btime값만큼 eventtime에서 빼줌 
            org_timestamp = obspy.UTCDateTime(year=year, julday=jday, hour=hour, minute=minute, second=sec, microsecond=msec).timestamp - st[0].stats.sac.b
            p_timestamp, s_timestamp = (org_timestamp + a), (org_timestamp + t0)
            pstime = s_timestamp - p_timestamp
            # 시간 계산 이후 hypo.phase에 들어갈 포맷으로 변경한 P파 도달시간을 ptime 변수에 입력
            p_utc, ptime = obspy.UTCDateTime(p_timestamp), obspy.UTCDateTime(p_timestamp).strftime('%y%m%d%H%M%S.%f')
            ptime = '{:.2f}'.format(np.float64(ptime))
            # S파 도달시간은 P파 도달시간을 기준으로 하기 때문에 datetime으로 계산하지 않고 먼저 P파 도달시간의 second, microsecond를 문자형으로 바꿔준 후 PS시를 더해주어 60초가 넘어도 1분으로 넘어가지 않고 그대로 입력되게끔 설정해줌
            # 어차피 hypo.phase에 집어넣으면 텍스트에 불과하기 때문에 ptime, stime 변수 string type으로 집어넣어도 무관
            if len(str(p_utc.microsecond)) < 6:
                p_utc_micro = '0' + str(p_utc.microsecond)
                stime = str(float(str(p_utc.second) + '.' + p_utc_micro) + pstime)
            else :
                stime = str(float(str(p_utc.second) + '.' + str(p_utc.microsecond)) + pstime)            # 위에서 구한 stime이 0초 이상 10초 미만 일 시 python에서는 '01:11'과 같이 출력되지 않고 '1:11'로 출력되기 때문에 hypo.phase가 인식할 수 있게끔 이러한 데이터들만 앞에 0을 수동으로 붙여줌 
            if re.match(r'^[1-9][.]', stime):
                stime = str('{:.2f}'.format(np.float64(stime), 2)).zfill(5)
            else:
                stime = '{:.2f}'.format(np.float64(stime), 2)
            # station명이 3글자일경우 뒤에 띄어쓰기를 무조건 해주어야 hypo.phase가 인식될 수 있음 -> 조건문 만들어서 예외 경우 만듬
            line = '{0:<4}{1:<5}{2:<22}{3}{4}'.format(tnm, ka, ptime, stime, kt0)
            # 위에서 만든 formatted line을 hypo.phase에 입력해주고 반복문 루프가 돌 때마다 줄 넘김까지 적용
            f.write(line + '\n')

def make_station(filename, wavedata_direction):
    station, unit_array = init(wavedata_direction)
    fe = FlinnEngdahl()
    with open(filename, 'a') as f:
        for i in unit_array:
            st = obspy.read(wavedata_direction + i)
            tnm = st[0].stats.sac.kstnm
            lat_org, lon_org, elev_org = station.loc[station.STATION == tnm].LATITUDE.values[0], station.loc[station.STATION == tnm].LONGITUDE.values[0], station.loc[station.STATION == tnm].ELEVATION.values[0]
            # dataframe의 위도와 경도값을 바탕으로 quadrant값을 받아오고, station.sta에 들어갈 수 있게끔 NS - WE 성분을 쪼개어 포맷팅합니다
            quad_ns, quad_we = fe.get_quadrant(lon_org, lat_org).upper()[0], fe.get_quadrant(lon_org, lat_org).upper()[1]
            # 계산 및 station.sta 포맷팅에 유용하게끔 위도, 경도값을 정수로 받아주고, 소숫점 아래 *60, 두자리만 출력되게끔 설정해주었습니다 
            int_lat, int_lon = int(lat_org), int(lon_org)
            lat, lon = np.round((lat_org - int_lat)*60,2), np.round((lon_org - int_lon)*60, 2)
            elev = int(elev_org.round(0))
            # station명이 3글자일경우, 위도/경도/해발고도 값에 예외경우가 있을 시 수정해주는 코드입니다.
            exp1, exp2, exp3 = re.compile('\d.\d\d'), re.compile('\d\d.\d'), re.compile('\d.\d')
            if exp1.fullmatch(str(lat)):
                lat = str(lat).zfill(5)
            elif exp2.fullmatch(str(lat)):
                lat = str(lat) + '0'
            elif exp3.fullmatch(str(lat)):
                lat = str(lat).zfill(4) + '0'
            if exp1.fullmatch(str(lon)):
                lon = str(lon).zfill(5)
            elif exp2.fullmatch(str(lon)):
                lon = str(lon) + '0'
            elif exp3.fullmatch(str(lon)):
                lon = str(lon).zfill(4) + '0'
            line = '{0:>4}{1:>2}{2}{3}{4:>4}{5}{6}{7:>5}\n{0:>4}*'.format(tnm, int_lat, quad_ns, lat, int_lon, quad_we, lon, elev)
            f.write(line + '\n')

