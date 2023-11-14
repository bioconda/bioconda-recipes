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
echo "XENOGI_DIR:str = '$PREFIX/lib/python$PYVER/site-packages/xenoGI'" >> $TEMP_FN

# add the last five lines of param.py (LPSN csv files)
tail -n 5 $PARAM_FN >> $TEMP_FN

# overwrite param.py with the new file
mv $TEMP_FN $PARAM_FN

# modify PHANTASM_PY variable so it prints the correct usage
sed -E "s/^(PHANTASM_PY = ).+$/\1'phantasm'/g" $PHANTASM_DIR/phantasm.py > $TEMP_FN
mv $TEMP_FN $PHANTASM_DIR/phantasm.py

# make an activate script
mkdir -p $ACTIVATE_DIR

# export variables for the activate script
echo "export BIN_DIR=$BIN_DIR" > $ACTIVATE_DIR/phantasm.sh
echo "export LIB_DIR=$PREFIX/lib/python" >> $ACTIVATE_DIR/phantasm.sh
echo 'export PYVER=$(python3 --version|sed -E "s/^\S+ ([0-9]+\.[0-9]+)\..+$/\1/g")' >> $ACTIVATE_DIR/phantasm.sh
echo 'export PHANTASM_DIR=$LIB_DIR$PYVER/site-packages/phantasm' >> $ACTIVATE_DIR/phantasm.sh
echo "export PHANTASM_EXE=$PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh

# write instructions to create a phantasm executable
echo 'echo "#! $(which python3)" | sed "s/ //g" > $PHANTASM_EXE' >> $ACTIVATE_DIR/phantasm.sh
echo "echo 'import os, sys, subprocess' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo -n 'sys.path.append(' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo 'echo -n "$PHANTASM_DIR" >> $PHANTASM_EXE' >> $ACTIVATE_DIR/phantasm.sh
echo "echo \"')\" >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo -n 'if __name__ == ' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo \"'__main__':\" >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo -n '    cmd = [' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo \"'python3', os.path.join('$PHANTASM_DIR', 'phantasm.py')]\" >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo '    cmd.extend(sys.argv[1:])' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo '    try:' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo '        subprocess.run(cmd, check=True)' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo '    except subprocess.CalledProcessError as e:' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "echo '        raise RuntimeError(e.stderr)' >> $PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh
echo "chmod a+x $PHANTASM_EXE"

# remove the variables
echo "unset BIN_DIR" >> $ACTIVATE_DIR/phantasm.sh
echo "unset LIB_DIR" >> $ACTIVATE_DIR/phantasm.sh
echo "unset PYVER" >> $ACTIVATE_DIR/phantasm.sh
echo "unset PHANTASM_DIR" >> $ACTIVATE_DIR/phantasm.sh
echo "unset PHANTASM_EXE" >> $ACTIVATE_DIR/phantasm.sh

# make activate script executable
chmod a+x $ACTIVATE_DIR/phantasm.sh
