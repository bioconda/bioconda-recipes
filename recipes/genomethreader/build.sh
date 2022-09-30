#!/bin/bash
mkdir -p $PREFIX/bin/{bssm,gthdata}
install $(ls -d bin/* | grep -v bssm | grep -v gthdata) $PREFIX/bin/
install bin/bssm/* $PREFIX/bin/bssm/
install bin/gthdata/* $PREFIX/bin/gthdata/
