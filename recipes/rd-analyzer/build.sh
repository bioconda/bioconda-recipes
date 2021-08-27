#!/bin/sh

RD_ANALYZER_DIR=${PREFIX}/share/RD-Analyzer
MAIN_CMD=${PREFIX}/bin/RD-Analyzer.py
echo '#!/usr/bin/env python' >$MAIN_CMD
cat RD-Analyzer.py >> $MAIN_CMD
chmod a+x $MAIN_CMD
