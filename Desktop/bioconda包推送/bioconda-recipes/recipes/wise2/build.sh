#!/usr/bin/env bash

mkdir _buildchain
export PATH="$(pwd)/_buildchain:$PATH"
[ -n $CC ] && ln -s $CC _buildchain/cc
[ -n $LD ] && ln -s $LD _buildchain/ld
[ -n $GCC ] && ln -s $GCC _buildchain/gcc
[ -n $GXX ] && ln -s $GCC _buildchain/g++
ls -l _buildchain

pushd src
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  corba/makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  dnaindex/assembly/makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  dnaindex/makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  dynlibsrc/makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  models/makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  network/makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  other_programs/makefile
sed -i.bak "s/glib-config --cflags/pkg-config --cflags glib-2.0/g"  snp/makefile

sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" makefile
sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" corba/makefile
sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" dnaindex/assembly/makefile
sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" dnaindex/makefile
sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" dynlibsrc/makefile
sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" models/makefile
sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" network/makefile
sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" other_programs/makefile
sed -i.bak "s/glib-config --libs/pkg-config --libs glib-2.0/g" snp/makefile

sed -i.bak "s/isnumber/isdigit/g" models/phasemodel.c
sed -i.bak "s/getline/getlineSeq/g" HMMer2/sqio.c

sed -i.bak "s/csh welcome.csh//g" makefile

make all
cp -v ./bin/* $PREFIX/bin/
mkdir $PREFIX/share/wise2
cp -rf ../wisecfg $PREFIX/share/wise2/
