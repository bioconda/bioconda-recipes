#!/bin/bash
$PYTHON setup.py build_ext --inplace --force
cp *.py ${PREFIX}/bin/
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/bam_to_tbi.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/compute_mappability.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/construct_synthetic_footprints.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/infer_CDS.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/learn_model.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/load_data.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/plot_model.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/setup.py
sed -i '1s/^/\#!\/usr\/bin\/env python\n/' ${PREFIX}/bin/utils.py
chmod 755 ${PREFIX}/bin/*.py
