#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export BOOST_INCLUDE=$PREFIX/include
export LD_LIBRARY_PATH="${PREFIX}/lib"

sed -i.bak '1d' Makefile

COMPILER=${CXX} make

echo "#!/bin/env/python" > ${PREFIX}/bin/run_pipeline.py
cat ./run_pipeline.py >> ${PREFIX}/bin/run_pipeline.py
cp ./correct.py ${PREFIX}/bin/correct.py
cp ./fast_scaled_scores.py ${PREFIX}/bin/fast_scaled_scores.py
cp ./get_seq.py ${PREFIX}/bin/get_seq.py
cp ./layout_unitigs.py ${PREFIX}/bin/layout_unitigs.py
cp ./make_links.py ${PREFIX}/bin/make_links.py
cp ./RE_sites.py ${PREFIX}/bin/RE_sites.py
cp ./refactor_breaks.py ${PREFIX}/bin/refactor_breaks.py
cp ./stitch.py ${PREFIX}/bin/stitch.py
cp ./break_contigs ${PREFIX}/bin/break_contigs
cp ./break_contigs_start ${PREFIX}/bin/break_contigs_start
cp ./correct_links  ${PREFIX}/bin/correct_links

chmod +x ${PREFIX}/bin/run_pipeline.py
chmod +x ${PREFIX}/bin/RE_sites.py
chmod +x ${PREFIX}/bin/break_contigs
chmod +x ${PREFIX}/bin/break_contigs_start
chmod +x ${PREFIX}/bin/correct.py
chmod +x ${PREFIX}/bin/fast_scaled_scores.py
chmod +x ${PREFIX}/bin/get_seq.py
chmod +x ${PREFIX}/bin/layout_unitigs.py
chmod +x ${PREFIX}/bin/make_links.py
chmod +x ${PREFIX}/bin/refactor_breaks.py
chmod +x ${PREFIX}/bin/stitch.py


