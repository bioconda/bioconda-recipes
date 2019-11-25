#!/bin/bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
esac

mkdir -p $PREFIX/bin

if [ $machine = "Linux" ]; then
awk -v rep="-fno-builtin-exp -fno-builtin-log -fno-builtin-pow -lstdc++ -lm" '{ gsub(/\-lstdc\+\+ \-lm/, rep); print }' > _install < install
mv install install_
mv _install install
fi

chmod +x install
./install -c $CXX -f " $CXXFLAGS"

shopt -s extglob
for file in $(compgen -G "Pretext!(*cpp)"); do
    chmod +x $file;
    mv $file $PREFIX/bin/
done
