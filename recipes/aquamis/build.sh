#!/bin/bash

mkdir -p $PREFIX/bin

mkdir -p $PREFIX/opt/aquamis/

cp -r * $PREFIX/opt/aquamis/

ln -s $PREFIX/opt/aquamis/scripts/aquamis_setup.sh $PREFIX/opt/aquamis/scripts/aquamis_wrapper.sh $PREFIX/opt/aquamis/scripts/create_sampleSheet.sh $PREFIX/opt/aquamis/scripts/create_pass_samplesheet.sh $PREFIX/opt/aquamis/scripts/filter_json.py $PREFIX/bin/

ln -s $PREFIX/opt/aquamis/aquamis.py $PREFIX/bin/aquamis

chmod -R u+x $PREFIX/bin/*
