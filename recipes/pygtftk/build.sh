ln -s $CC `dirname $CC`/gcc
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
cp bin/* $PREFIX/bin/
