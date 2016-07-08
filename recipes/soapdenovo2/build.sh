#!/bin/sh

set -x -e

mkdir -p $PREFIX/bin
cp -rf SOAP* $PREFIX/bin

#https://sourceforge.net/projects/soapdenovo2/files/SOAPdenovo2/bin/r240/SOAPdenovo2-bin-r240-mac.tgz/download
# This is the MACOSX version
