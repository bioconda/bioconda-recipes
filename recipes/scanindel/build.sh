#!/bin/bash

mkdir -p $PREFIX/bin
sed -i -e 's|#!/usr/bin/python|#!/usr/bin/env python|g' ScanIndel.py
sed -i -e 's|#!/usr/bin/python|#!/usr/bin/env python|g' tools/vcf-combine.py
cp ScanIndel.py $PREFIX/bin
cp tools/* $PREFIX/bin
