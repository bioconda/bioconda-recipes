mkdir -p $PREFIX/bin
mv ./* $PREFIX
ln -sfv $PREFIX/fastcov.py $PREFIX/bin/fastcov
ln -sfv $PREFIX/fastcov.py $PREFIX/bin/fastcov.py