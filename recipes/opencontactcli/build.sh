#!/bin/bash
mkdir -p $PREFIX/bin
cp src/main_cli.py src/*.f src/*.pdb src/*j* $PREFIX/bin
chmod 0766 $PREFIX/bin/main_cli.py
ln -s $PREFIX/bin/main_cli.py $PREFIX/bin/OpenContactCLI
cd  $PREFIX/bin
f2py -c --help-fcompiler
f2py -c -m it inputgui.f
f2py -c -m contact contactgui.f
if [ ! -e it.so ]; then ln -s it*.so it.so; fi
if [ ! -e contact.so ]; then ln -s contact*.so contact.so; fi
