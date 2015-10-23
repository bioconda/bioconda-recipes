#!/bin/bash -eu

ln -sf $PREFIX/jre/lib/amd64/libjava.so $PREFIX/lib/libjava.so
ln -sf $PREFIX/jre/lib/amd64/server/libjvm.so $PREFIX/lib/libjvm.so
ln -sf $PREFIX/jre/lib/amd64/libnet.so $PREFIX/lib/libnet.so
ln -sf $PREFIX/jre/lib/amd64/libverify.so $PREFIX/lib/libverify.so
