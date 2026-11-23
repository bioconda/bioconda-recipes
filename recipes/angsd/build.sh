#! /bin/bash

mkdir -p ${PREFIX}/bin

make HTSSRC="systemwide" prefix="${PREFIX}" CC="${CC}" CXX="${CXX}" install-all
