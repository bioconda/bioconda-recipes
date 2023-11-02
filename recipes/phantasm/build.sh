#!/bin/bash

# export variables
export TEMP_FN=".tmp"
export BIN_DIR=$PREFIX/bin
export PHANTASM_DIR=$PREFIX/phantasm
export PARAM_FN=$PHANTASM_DIR/param.py
export PYVER=$(python -c 'import sys; v=[str(x) for x in sys.version_info[:]]; print(".".join(v[:2]))')

# move phantasm files to the directory
mkdir -p $PHANTASM_DIR
cp -rf ./ $PHANTASM_DIR

# define global variables that point at the executables
echo "BLASTPLUS_DIR:str = '$BIN_DIR'" > $TEMP_FN
echo "MUSCLE_EXE:str = '$BIN_DIR/muscle'" >> $TEMP_FN
echo "FASTTREE_EXE:str = '$BIN_DIR/FastTreeMP'" >> $TEMP_FN
echo "IQTREE_EXE:str = '$BIN_DIR/iqtree'" >> $TEMP_FN

# define global variables that point at phantasm and xenogi directories
echo "PHANTASM_DIR:str = '$PHANTASM_DIR'" >> $TEMP_FN
echo "XENOGI_DIR:str = '$PREFIX/lib/python$PYVER/site-packages/xenoGI'" >> $TEMP_FN

# add the last five lines of param.py (LPSN csv files)
tail -n 5 $PARAM_FN >> $TEMP_FN

# overwrite param.py with the new file
mv $TEMP_FN $PARAM_FN
