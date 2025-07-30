#!/bin/bash
mkdir -p ${PREFIX}/bin

cd src

$CC -o $PREFIX/bin/nedbit-features-calculator nedbit_features_calculator.c -lm

chmod u+x ${PREFIX}/bin/nedbit-features-calculator
