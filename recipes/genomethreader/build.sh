#!/bin/bash
mkdir -p $PREFIX/bin/{bssm,gthdata}
install bin/* $PREFIX/bin/
install bin/bssm/* $PREFIX/bin/bssm/
install bin/gthdata/* $PREFIX/bin/gthdata/
