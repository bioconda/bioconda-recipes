#!/bin/bash
make

cat test/tantan_test.sh | perl -pe 's/diff/diff -w/' > test/tantan_test.fixed.sh
sh test/tantan_test.fixed.sh

make install prefix=$PREFIX
