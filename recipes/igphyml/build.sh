mv $( pwd ) $PREFIX/share/igphyml
./make_phyml
mkdir -p $PREFIX/bin
ln -s $PREFIX/share/igphyml/src/igphyml $PREFIX/bin/igphyml
rm $PREFIX/share/igphyml/compile $PREFIX/share/igphyml/missing $PREFIX/share/igphyml/decomp $PREFIX/share/igphyml/con* $PREFIX/share/igphyml/install-sh $PREFIX/share/igphyml/INSTALL
