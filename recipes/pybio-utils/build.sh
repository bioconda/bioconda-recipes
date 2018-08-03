#!/bin/bash
sed -i 's/0.2.8/0.2.10/' requirements.txt
$PYTHON setup.py install
cp bio_utils/*.py ${PREFIX}/bin/
cp bio_utils/bio_programs/*.py ${PREFIX}/bin/
cp bio_utils/bio_programs/plotting/*.py ${PREFIX}/bin/
cp tests/*.py ${PREFIX}/bin/
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/*.py
chmod 755 ${PREFIX}/bin/*.py
