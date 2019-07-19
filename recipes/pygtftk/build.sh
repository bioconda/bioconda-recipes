ln -s $CC `dirname $CC`/gcc
$PYTHON -m pip install --no-deps --ignore-installed --no-cache-dir -vvv .
#$PYTHON setup.py install --single-version-externally-managed --record=record.txt
cp bin/* $PREFIX/bin/
