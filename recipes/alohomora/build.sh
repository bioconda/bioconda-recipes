#!/bin/bash

for scr in alohomora_M_v0.33_linux.pl scripts/{*.sh,*.pl}; do
    sed -i".bak" "1 s|^.*$|#!/usr/bin/env perl|" $scr
    dos2unix $scr
    chmod +x $scr
done

cp -v scripts/{*.pl,*.sh} $PREFIX/bin/
cp -v alohomora_M_v0.33_linux.pl $PREFIX/bin/alohomora

