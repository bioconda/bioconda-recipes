#!/usr/bin/env bash
mkdir -p $PREFIX/Colombo
cp -r . $PREFIX/Colombo
mkdir -p $PREFIX/bin
ln -s $PREFIX/Colombo/Colombo/SigiHMM $PREFIX/bin
ln -s $PREFIX/Colombo/Colombo/mSigiHMM $PREFIX/bin
ln -s $PREFIX/Colombo/Colombo/SigiCRF $PREFIX/bin
ln -s $PREFIX/Colombo/Colombo/Colombo $PREFIX/bin
chmod +x $PREFIX/bin/*