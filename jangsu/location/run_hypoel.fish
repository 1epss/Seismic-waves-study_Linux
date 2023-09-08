#!/usr/bin/env fish

set location (path resolve (dirname (status current-command)))

cd $location
hypoel < $location/input_file/hypo.in
