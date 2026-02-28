#!/bin/bash

set -eux

make

mkdir -p ${PREFIX}/bin/
cp ParDRe ${PREFIX}/bin/
