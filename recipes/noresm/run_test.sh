#!/bin/bash
set -e

export NETCDF_DIR=$(nc-config --prefix)
export CIME_MODEL=cesm
export CESM_DATA_ROOT=$HOME
export CESM_WORK_ROOT=$HOME

# export AR=---
mkdir -p $CESM_DATA_ROOT/inputdata

create_newcase --case $CESM_WORK_ROOT/cases/NF2000climo  --compset NF2000climo --res f19_f19_mg17 --machine espresso --run-unsupported

cd $CESM_WORK_ROOT/cases/NF2000climo
./case.setup
./case.build

cd -

rm -rf $CESM_WORK_ROOT/cases/NF2000climo
rm -rf $CESM_WORK_ROOT/$CIME_MODEL/work/NF2000climo
