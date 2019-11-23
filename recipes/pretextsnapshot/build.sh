#!/bin/bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
esac

mkdir -p $PREFIX/bin

if [ $machine = "Linux" ]; then
awk -v rep="-static -Wl,-rpath,/usr/lib/ -Wl,-rpath-link,/usr/lib/ -L/usr/lib/ -lstdc++ -lm" '{ gsub(/\-lstdc\+\+ \-lm/, rep); print }' > _install < install
mv install install_
mv _install install
fi

chmod +x install
./install

shopt -s extglob
for file in $(compgen -G "Pretext!(*cpp)"); do
    chmod +x $file;
    mv $file $PREFIX/bin/
done
