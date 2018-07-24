#!/bin/bash
$PYTHON setup.py build_ext --inplace --force
$PYTHON setup.py install
cp *.py ${PREFIX}/bin/
cp *.pyx ${PREFIX}/bin/
cp *.pxd ${PREFIX}/bin/
cp -r data/kozak_model.npz $PREFIX/share/kozak_model.npz
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/bam_to_tbi.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/compute_mappability.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/construct_synthetic_footprints.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/infer_CDS.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/learn_model.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/load_data.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/plot_model.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/setup.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/utils.py
sed -i 's@data/kozak_model.npz@'"$PREFIX"'/share/kozak_model.npz@' ${PREFIX}/bin/seq.pyx
chmod 755 ${PREFIX}/bin/*.py
