#!/bin/bash
set -vex

cd pypeflow
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
cd falcon_kit
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
cd falcon_unzip
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
cd falcon_phase
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..

cd pb-falcon-phase

cd src
echo ${CC}
which ${CC}
meson --buildtype=release ./build-meson
ninja -C ./build-meson -v
cp -f ./build-meson/falcon-phase ${PREFIX}/bin
cd ..

cd bin
ls -larth
cp fc_coords2hp.py fc_emit_haplotigs.py fc_filt_hp.py fc_primary_contig_index.pl fc_scrub_names.pl FALCON_headerConverter.pl $PREFIX/bin
cd ..

cd ..
