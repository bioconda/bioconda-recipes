#!/bin/bash

mkdir -p $PREFIX/bin

# Fix perl path
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ITSx

mv ITSx $PREFIX/bin
mv ITSx_db/ $PREFIX/bin/
chmod +x $PREFIX/bin/ITSx
