#!/bin/bash
$PYTHON setup.py build_ext --inplace --force
$PYTHON setup.py install
cp *.py ${PREFIX}/bin/
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/bam_to_tbi.py
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/compute_mappability.py
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/construct_synthetic_footprints.py
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/infer_CDS.py
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/learn_model.py
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/load_data.py
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/plot_model.py
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/setup.py
sed -i '#!/usr/bin/env python' ${PREFIX}/bin/utils.py
chmod 755 ${PREFIX}/bin/*.py
