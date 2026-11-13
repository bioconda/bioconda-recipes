#!/bin/bash

UNAME=$(uname)

get_needed_Darwin() {
    otool -L "$1" | tail -n +2 | awk '{print $1}'
}
get_needed_Linux() {
    patchelf --print-needed "$1"
}
get_needed() {
    get_needed_$UNAME "$@"
}
exclude_haves() {
    grep -vE "^/(lib|usr|System)|lib(ARBDB|CORE|stdc\+\+|c\+\+|glib-2.0|m|c|gcc_s|pthread)\."
}

mkdir -p $PREFIX/lib/arb/bin
for bin in install/lib/arb/bin/arb_*; do
    echo checking $bin
    if [ ! -L "$bin" -a -z "`get_needed $bin | exclude_haves`" ]; then
	mv $bin $PREFIX/lib/arb/bin
	echo   installed
	echo   needs libs: `get_needed $bin`
    fi
done

echo Creating Symlinks
(
    cd $PREFIX/bin
    for binary in ../lib/arb/bin/arb_*; do
	ln -s "$binary"
	echo "  $binary"
    done
)
