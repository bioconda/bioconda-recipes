#!/bin/bash

mkdir -p $PREFIX/bin

make

mv BaitFisher-v1.2.7 $PREFIX/bin/BaitFisher
mv BaitFilter-v1.0.5 $PREFIX/bin/BaitFilter

