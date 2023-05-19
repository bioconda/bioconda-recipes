#!/bin/bash

for script in MethylExtract*.pl; do
	sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $script;
done

mkdir -p $PREFIX/bin/
cp -r *.pl $PREFIX/bin/
