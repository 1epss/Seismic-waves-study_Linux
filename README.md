# Seismic-waves-study_Linux

analyzing seismic waves with Seismic Analysis Code (SAC) &amp; Hypoellipse on Ubuntu


## 개요

Windows - Cygwin 환경에서 [SAC](https://ds.iris.edu/ds/nodes/dmc/software/downloads/SAC/102-0/)과 [Hypoellipse](https://pubs.usgs.gov/of/1999/ofr-99-0023/)를 이용한 지진파 분석을 Linux (Ubuntu 23.04) - GNOME-shell 44.3 환경에서 동일하게 실행하기 위한 코드입니다.


## 과정

1) NECIS에서 수집한 MSEED 데이터 전처리 및 [MSEED2SAC](https://github.com/iris-edu/mseed2sac)을 이용한 SAC 변환
```bash
mseed2sac [options] file1 [file2 file3 ...]
```

2) SAC을 이용한 지진 파형 분석 및 자료 처리
```
sac

SAC > r *.sac
SAC > qdp off
SAC > fileid loc ul type list kstnm kcmpnm dist az
SAC > sort dist
SAC > ppk a p 3 m on
```
3) Hypoellipse를 이용한 진원 계산
```bash
~/home/hypoellipse/hypoel/Hypoel < ~/home/jangsu/location/input_file/hypo.in
```

