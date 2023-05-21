#!/bin/bash

mkdir -p $PREFIX/bin
for i in transIndel_*.py; do 
  sed -i.bak '1s|^|#!/usr/bin/env python\'$'\n|g' ${i};
  chmod 755 ${i};
  cp ${i} $PREFIX/bin/;
done
