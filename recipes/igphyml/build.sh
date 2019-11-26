mv $( pwd ) $PREFIX/share/igphyml
./make_phyml
mkdir -p $PREFIX/bin
ln -s $PREFIX/share/igphyml/src/igphyml $PREFIX/bin/igphyml
