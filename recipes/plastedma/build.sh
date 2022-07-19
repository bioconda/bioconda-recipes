mkdir -p $PREFIX/
mkdir -p $PREFIX/opt
cp -r * $PREFIX/opt/
ln -s $PREFIX/opt/workflow $PREFIX/bin
ln -s $PREFIX/opt/plastedma.py $PREFIX/bin
chmod +x $PREFIX/bin/plastedma.py