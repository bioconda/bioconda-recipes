#!/bin/bash

chmod u+x MEGAN_Community_unix_6_12_3.sh

MEGAN="$PEFIX/opt/$PKG_NAME-$PKG_VERSION"
./MEGAN_Community_unix_6_12_3.sh -q -dir "$MEGAN"

mkdir -p "$PREFIX"/bin/

find "$MEGAN" -type f | while read -r file
do
	ln -s "$file" "$PREFIX"/bin/"$(basename "$file")"
done

# -varfile [file] responsefile
# -c console mode
# -q unattended mode
# -dir [DIR] installation dir
# -overwrite 
# -splash [TITLE] show progress
# -Dname=value system properties


# 
# fastqc=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
# mkdir -p $fastqc
# cp -r ./* $fastqc
# sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $fastqc/fastqc
# rm -f $fastqc/fastqc.bak
# chmod +x $fastqc/fastqc
# mkdir -p $PREFIX/bin
# ln -s $fastqc/fastqc $PREFIX/bin/fastqc 

