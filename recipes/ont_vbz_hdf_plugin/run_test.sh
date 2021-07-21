#!/usr/bin/env bash


pwd
ls 
set

ls test_data
test -r test_data/multi_fast5_vbz_v1.fast5
h5dump test_data/multi_fast5_vbz_v1.fast5 >/dev/null
