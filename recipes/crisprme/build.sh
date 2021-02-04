#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crisprme"
chmod -R 700 .
cp crisprme.py "${PREFIX}/bin/"
cp -R auto_search_corrected "${PREFIX}/opt/crisprme/"
