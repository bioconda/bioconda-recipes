mkdir -p $PREFIX/bin
cp danpos.py $PREFIX/bin/danpos
chmod +x $PREFIX/bin/danpos
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
