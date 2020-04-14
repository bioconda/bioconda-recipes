#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin
sed -i.bak '1 i\#!/usr/bin/env perl' scripts/seeker.pl

cp scripts/* ${PREFIX}/bin/
chmod 0755 ${PREFIX}/bin/*
