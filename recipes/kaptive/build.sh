#!/bin/bash
mkdir -p $PREFIX/bin
mv kaptive.py $PREFIX/bin
chmod +x $PREFIX/bin/kaptive.py
mkdir -p $PREFIX/opt/kaptive_reference_database
mkdir -p $PREFIX/opt/kaptive_sample_data

mv $SRC_DIR/reference_database/*.* $PREFIX/opt/kaptive_reference_database/
mv $SRC_DIR/sample_data/*.* $PREFIX/opt/kaptive_reference_database/
