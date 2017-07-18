#!/bin/bash

export PATH="$PATH:$PREFIX"
cd "xcftools-196f51790bbaff594525935adeab1247bb798946"

./configure --prefix=$PREFIX
make all
make install
