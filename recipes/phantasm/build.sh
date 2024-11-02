#!/bin/bash

# create variables for this build script
export PYVER=$(python3 --version|sed -E "s/^\S+ ([0-9]+\.[0-9]+)\..+$/\1/g")
export TEMP_FN=".tmp"
export BIN_DIR=$PREFIX/bin
export ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
export PHANTASM_EXE=$BIN_DIR/phantasm
export PHANTASM_DIR=$PREFIX/lib/python$PYVER/site-packages/phantasm
export PARAM_FN=$PHANTASM_DIR/param.py

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
echo "XENOGI_DIR:str = '$PREFIX/lib/python$PYVER/site-packages/'" >> $TEMP_FN

# add the last five lines of param.py (LPSN csv files)
tail -n 5 $PARAM_FN >> $TEMP_FN

# overwrite param.py with the new file
mv $TEMP_FN $PARAM_FN

# modify PHANTASM_PY variable so it prints the correct usage
sed -E "s/^(PHANTASM_PY = ).+$/\1'phantasm'/g" $PHANTASM_DIR/phantasm.py > $TEMP_FN
mv $TEMP_FN $PHANTASM_DIR/phantasm.py

# make the phantasm executable
touch $PHANTASM_EXE
chmod a+x $PHANTASM_EXE

# make an activate script
mkdir -p $ACTIVATE_DIR

# export variables for the activate script
cat <<End > $ACTIVATE_DIR/phantasm.sh
export BIN_DIR=$BIN_DIR
export LIB_DIR=$PREFIX/lib/python
export PHANTASM_EXE=$PHANTASM_EXE
export BUILD_PYVER=$PYVER
End

# PYVER and PHANTASM_DIR need to be defined upon activation
cat <<\End >> $ACTIVATE_DIR/phantasm.sh
export PYVER=$(python3 --version|sed -E "s/^\S+ ([0-9]+\.[0-9]+)\..+$/\1/g")
export PHANTASM_DIR=$LIB_DIR$PYVER/site-packages/phantasm
End

# replace the build pyver with the current pyver
cat <<\End >> $ACTIVATE_DIR/phantasm.sh
cat $PHANTASM_DIR/param.py | sed -E "s/python$BUILD_PYVER/python$PYVER/g" > .tmp
mv .tmp $PHANTASM_DIR/param.py
End

# start building the python executable
cat <<End >> $ACTIVATE_DIR/phantasm.sh
echo "#!/usr/bin/env python3" > $PHANTASM_EXE
echo "import os, sys, subprocess" >> $PHANTASM_EXE
End

# $PHANTASM_DIR needs to be evaluated as string literal
cat <<\End >> $ACTIVATE_DIR/phantasm.sh
echo "sys.path.append('$PHANTASM_DIR')" >> $PHANTASM_EXE
End

# continue building python executable
cat <<End >> $ACTIVATE_DIR/phantasm.sh
echo "if __name__ == '__main__'": >> $PHANTASM_EXE
End

# PHANTASM_DIR needs to be evalutated as a string literal
cat <<\End >> $ACTIVATE_DIR/phantasm.sh
echo "    cmd = ['python3', os.path.join('$PHANTASM_DIR', 'phantasm.py')]" >> $PHANTASM_EXE
End

# finish building python executable and unset variables
cat <<End >> $ACTIVATE_DIR/phantasm.sh
echo "    cmd.extend(sys.argv[1:])" >> $PHANTASM_EXE
echo "    try:" >> $PHANTASM_EXE
echo "        subprocess.run(cmd, check=True)" >> $PHANTASM_EXE
echo "    except subprocess.CalledProcessError as e:" >> $PHANTASM_EXE
echo "        raise RuntimeError(e.stderr)" >> $PHANTASM_EXE
unset BIN_DIR
unset LIB_DIR
unset BUILD_PYVER
unset PYVER
unset PHANTASM_DIR
unset PHANTASM_EXE
End

# make activate script executable
chmod a+x $ACTIVATE_DIR/phantasm.sh
