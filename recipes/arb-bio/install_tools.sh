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
    if [ ! -L "$bin" -a -z "`get_needed $bin | exclude_haves`" ]; then
	echo installing $bin
	echo `get_needed $bin`
	mv $bin $PREFIX/lib/arb/bin
    fi
done

(
    cd $PREFIX/bin
    for binary in ../lib/arb/bin/arb_*; do
	ln -s "$binary"
    done
)
