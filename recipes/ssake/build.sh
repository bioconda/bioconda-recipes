#!/bin/bash

cp ssake/SSAKE ${PREFIX}/bin
cp ssake/tools/*.pl ${PREFIX}/bin
cp ssake/tools/*.py ${PREFIX}/bin

chmod +x ${PREFIX}/bin/*.py
chmod +x ${PREFIX}/bin/*.pl
chmod +x ${PREFIX}/bin/SSAKE
