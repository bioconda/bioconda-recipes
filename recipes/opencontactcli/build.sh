#!/bin/bash
mkdir -p $PREFIX/bin
cp src/main_cli.py src/*.f src/*.pdb src/*j* $PREFIX/bin
chmod 0766 $PREFIX/bin/main_cli.py
ln -s $PREFIX/bin/main_cli.py $PREFIX/bin/OpenContactCLI
cd  $PREFIX/bin
# cd src
which f2py
f2py -c --help-fcompiler
f2py -c -m it inputgui.f
f2py -c -m contact contactgui.f
# cp -p *.so* $PREFIX/bin/
#cp -p it.p* $PREFIX/bin/
#cp -p contact.p* $PREFIX/bin/
cp -p *.so* $PREFIX/lib/
ls -ltr
