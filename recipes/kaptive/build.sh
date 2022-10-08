#!/bin/bash
python -m pip install . --ignore-installed --no-deps -vv
mkdir -p $PREFIX/opt/kaptive_reference_database
mkdir -p $PREFIX/opt/kaptive_sample_data

mv $SRC_DIR/reference_database/*.* $PREFIX/opt/kaptive_reference_database/
mv $SRC_DIR/sample_data/*.* $PREFIX/opt/kaptive_reference_database/