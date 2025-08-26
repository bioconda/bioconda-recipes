#!/bin/bash
mkdir -p $PREFIX/bin
cp assignAlleleCodes_py3.6.py $PREFIX/bin/assignAlleleCodes
chmod +x $PREFIX/bin/assignAlleleCodes
# ensure backward compatibility
ln -sv assignAllelecodes $PREFIX/bin/assignAlleleCodes_py3.6
