#!/bin/bash

cd src
make
make install

mv ../bin/gkmtrain $PREFIX/bin
mv ../bin/gkmpredict $PREFIX/bin
