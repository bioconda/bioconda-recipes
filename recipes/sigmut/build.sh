#!/bin/bash

set -e
./sigprofiler -ig GRCh38
cp * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/*
