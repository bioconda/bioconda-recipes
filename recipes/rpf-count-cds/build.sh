#!/bin/bash
sed -i.bak '1s|^|#!/usr/bin/env python\'$'\n|g' RPF_count_CDS.py
sed -i.bak '1s|^|#!/usr/bin/env python\'$'\n|g' RPF_count_CDS_nonStranded.py
cp RPF_count_CDS.py $PREFIX/bin
cp RPF_count_CDS_nonStranded.py $PREFIX/bin
chmod 755 $PREFIX/bin/RPF_count_CDS.py
chmod 755 $PREFIX/bin/RPF_count_CDS_nonStranded.py
