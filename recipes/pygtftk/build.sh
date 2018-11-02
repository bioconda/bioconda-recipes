ln -s $CC `dirname $CC`/gcc
$PYTHON -m pip install --no-deps --ignore-installed --no-cache-dir -vvv .
cp bin/* $PREFIX/bin/
