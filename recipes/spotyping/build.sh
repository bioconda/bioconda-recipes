#!/bin/sh

SPOTYPING_DIR=${PREFIX}/share/SpoTyping
mkdir $SPOTYPING_DIR
cp -r SpoTyping-v${PKG_VERSION}-commandLine/* $SPOTYPING_DIR

PLOT_CMD=${PREFIX}/bin/SpoTyping_plot.r
echo '#!/usr/bin/env Rscript' > $PLOT_CMD
cat SpoTyping-v${PKG_VERSION}-commandLine/SpoTyping_plot.r >> $PLOT_CMD
chmod a+x $PLOT_CMD

MAIN_CMD=${PREFIX}/bin/SpoTyping.py
echo '#!/usr/bin/env python' >$MAIN_CMD
cat SpoTyping-v${PKG_VERSION}-commandLine/SpoTyping.py >> $MAIN_CMD
chmod a+x $MAIN_CMD
