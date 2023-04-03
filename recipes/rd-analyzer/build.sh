#!/bin/sh

RD_ANALYZER_DIR=${PREFIX}/share/RD-Analyzer
mkdir -p $RD_ANALYZER_DIR
cp -r *py $RD_ANALYZER_DIR

cp -r Reference $RD_ANALYZER_DIR/

mkdir -p ${PREFIX}/bin

MAIN_CMD=${PREFIX}/bin/RD-Analyzer.py
echo '#!/usr/bin/env python' >$MAIN_CMD
cat RD-Analyzer.py >> $MAIN_CMD
chmod a+x $MAIN_CMD


EXTENDED_MAIN_CMD=${PREFIX}/bin/RD-Analyzer-extended.py
echo '#!/usr/bin/env python' >$EXTENDED_MAIN_CMD
cat RD-Analyzer-extended.py >> $EXTENDED_MAIN_CMD
chmod a+x $EXTENDED_MAIN_CMD
