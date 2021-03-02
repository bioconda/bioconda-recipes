#!/bin/bash

mkdir -p $PREFIX/bin

mkdir -p $PREFIX/opt/aquamis/

cp -r * $PREFIX/opt/aquamis/

ln -s $PREFIX/opt/aquamis/scripts/aquamis_setup.sh $PREFIX/opt/aquamis/scripts/create_sampleSheet.sh $PREFIX/opt/aquamis/scripts/filter_json.py $PREFIX/opt/aquamis/scripts/parse_json.py $PREFIX/opt/aquamis/scripts/helper_functions.py $PREFIX/opt/aquamis/scripts/write_QC_report.Rmd $PREFIX/opt/aquamis/scripts/write_report.Rmd  $PREFIX/bin/

ln -s $PREFIX/opt/aquamis/aquamis.py $PREFIX/bin/aquamis

chmod -R u+x $PREFIX/bin/*
