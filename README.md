# Seismic-waves-study_Linux

analyzing seismic waves with Seismic Analysis Code (SAC) &amp; Hypoellipse on Ubuntu


## Overview

A repository to analyze seismic waves with [SAC](https://ds.iris.edu/ds/nodes/dmc/software/downloads/SAC/102-0/) and [Hypoellipse](https://pubs.usgs.gov/of/1999/ofr-99-0023/) in Linux (Ubuntu 23.04).


## Getting Started

1) Convert miniseed data to SAC format with [MSEED2SAC](https://github.com/iris-edu/mseed2sac)

```bash
mseed2sac [options] file1 [file2 file3 ...]
```

2) Preprocess and analyze seismic waves with SAC

```
# picking body waves

sac

SAC > r *.sac
SAC > qdp off
SAC > fileid loc ul type list kstnm kcmpnm dist az
SAC > sort dist
SAC > ppk a p 3 m on
```

3) Make Hypo.phase and Station.sta with picked seismic waves
   
   You can go through the next step by running [`config.ipynb`](scripts/config.ipynb) or ['config.sh'](scripts/config.sh).
   It will automatically make `hypo.phase` and `station.sta` from your analyzed seismic data.
   
```python3
make_hypo('hypo.phase', '../jangsu/dist100_station/')
make_station('station.sta', '../jangsu/dist100_station/')
```

```bash
cd scripts
./config.sh
```

4) Calculate depth of an earthquake and visualize the location of each station with Hypoellipse

```bash
cd jangsu2/location
../../hypoellipse/hypoel/Hypoel < input_file/hypo.in
```

### KR_earthquake_station

A directory for collecting data of station with [Selenium](https://www.selenium.dev/documentation/webdriver/).
By running [`korea_instrument.ipynb`](KR_earthquake_station/korea_instrument.ipynb), you can get preprocessed station data from [NECIS](https://necis.kma.go.kr/necis-dbf/user/common/userLoginNewForm.do) but it requires sign up process.


## Setting up environment with Nix

You need to have [Nix](https://nixos.org/download) installed, with [flakes enabled](https://nixos.wiki/wiki/Flakes#Other_Distros:_Without_Home-Manager).

In the repo directory, run
```sh
nix develop
```
and you will get a shell with all tools needed to compile `Hypoel` and run Python.


### Getting `nix develop` to automatically run

Get [direnv](https://direnv.net/docs/installation.html). It should ask you to enable the `.envrc` configuration
when you are in this folder.
To activate it, run
```sh
direnv allow
```
