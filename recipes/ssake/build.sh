#!/bin/bash

chmod +x ssake/SSAKE
chmod +x ssake/tools/*.pl
chmod +x ssake/tools/*.py

mkdir -p ${PREFIX}/bin
cp ssake/SSAKE ${PREFIX}/bin
cp ssake/tools/*.pl ${PREFIX}/bin
cp ssake/tools/*.py ${PREFIX}/bin
