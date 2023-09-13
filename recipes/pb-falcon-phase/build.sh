#!/usr/bin/env bash
set -vex

cd pb-falcon-phase

cd src
echo ${CC}
which ${CC}
meson --prefix "${PREFIX}" --buildtype=release ./build-meson
ninja -C ./build-meson -v install
#cp -f ./build-meson/falcon-phase ${PREFIX}/bin # we want RPATH munging from Meson
cd ..

cd bin
ls -larth
cp -a fc_primary_contig_index.pl fc_scrub_names.pl FALCON_headerConverter.pl ${PREFIX}/bin
cd ..
