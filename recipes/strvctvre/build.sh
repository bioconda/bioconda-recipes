#!/bin/bash

chmod a+x *.py
mkdir -p $PREFIX/bin
cp *.py $PREFIX/bin/

# Add missing shebang lines
sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $PREFIX/bin/StrVCTVRE.py
sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $PREFIX/bin/annotationFinalForStrVCTVRE.py
sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $PREFIX/bin/liftover_hg19_to_hg38_public.py
sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $PREFIX/bin/test_StrVCTVRE.py
sed -i.bak '1s/.*/#!\/usr\/bin\/env python3/' $PREFIX/bin/test_StrVCTVRE_GRCh37.py
