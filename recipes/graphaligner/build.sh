#!/usr/bin/env bash

cd $SRC_DIR
ls -la $PREFIX/lib/
echo $LIBRARY_PATH
export LIBRARY_PATH=$LIBRARY_PATH:$PREFFIX/lib
echo $LIBRARY_PATH
exit 1
#make bin/GraphAligner
#cp bin/GraphAligner $PREFIX/bin
