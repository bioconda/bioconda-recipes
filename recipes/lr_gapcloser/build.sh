#!/bin/bash

export LC_ALL="en_US.UTF-8"

mkdir -p "${PREFIX}/bin"

chmod +rwx src/LR_Gapcloser.sh

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/*.pl
sed -i.bak '1 s|#!/bin/bash|#!/usr/bin/env bash|g' src/LR_Gapcloser.sh

rm -f src/*.bak

install -v -m 0755 src/*.pl "${PREFIX}/bin"
install -v -m 0755 src/LR_Gapcloser.sh "${PREFIX}/bin"
