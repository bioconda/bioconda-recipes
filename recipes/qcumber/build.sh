#!/bin/bash

# grep adapters from trimmomatic


if [ -a "$CONDA_PREFIX/share/trimmomatic/adapters" ]; then 
cat $CONDA_PREFIX/share/trimmomatic/adapters/*  > config/adapters.fa
adapter_path=$CONDA_PREFIX/share/trimmomatic/adapters/; 
else 
cat $CONDA_PREFIX/../../../share/trimmomatic/adapters/* > config/adapters.fa
adapter_path=$CONDA_PREFIX/../../../share/trimmomatic/adapters/; 
fi 

mkdir -p $CONDA_PREFIX/opt/qcumber/
cp -r * $CONDA_PREFIX/opt/qcumber/
#sed -i.bak "1c\#!$PYTHON" $CONDA_PREFIX/opt/qcumber/QCumber-2
sed -i.bak "s#ADAPTER_PATH = \"\"#ADAPTER_PATH = \"$adapter_path\"#g" $CONDA_PREFIX/opt/qcumber/QCumber-2

ln -s $CONDA_PREFIX/opt/qcumber/QCumber-2 $CONDA_PREFIX/bin/
chmod u+x $CONDA_PREFIX/bin/QCumber-2
