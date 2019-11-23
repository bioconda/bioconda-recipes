#!/bin/bash

mkdir -p $PREFIX/bin

if [[ -v LD_RUN_PATH ]]; then
    awk -v rep="-static -Wl,-rpath,/usr/lib/x86_64-linux-gnu/ -Wl,-rpath-link,/usr/lib/x86_64-linux-gnu/ -L/usr/lib/x86_64-linux-gnu/ -lstdc++ -lm" '{ gsub(/\-lstdc\+\+ \-lm/, rep); print }' > _install < install
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
