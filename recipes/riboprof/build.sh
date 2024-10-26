#!/bin/bash

cd src
make riboprof INC="-I${PREFIX}/include"
cp riboprof ${PREFIX}/bin