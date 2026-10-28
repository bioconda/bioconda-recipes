#!/bin/bash

mkdir -p ${PREFIX}/bin

chmod +x DIEGO/*.py
chmod +x DIEGO/*.pl

mv DIEGO/*.py ${PREFIX}/bin/
mv DIEGO/*.pl ${PREFIX}/bin/
