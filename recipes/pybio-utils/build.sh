#!/bin/bash
$PYTHON setup.py install
cp bio_utils/*.py ${PREFIX}/bin/
cp bio_utils/bio_programs/*.py ${PREFIX}/bin/
cp bio_utils/bio_programs/plotting/*.py ${PREFIX}/bin/
cp tests/*.py ${PREFIX}/bin/

sed -i 's/misc/pymisc_utils/' ${PREFIX}/bin/*.py
sed -i '0,/import pymisc_utils/ s/import pymisc_utils/pymisc_utils = __import__("pymisc-utils")\nimport pymisc_utils/' ${PREFIX}/bin/*.py

chmod 755 ${PREFIX}/bin/*.py
