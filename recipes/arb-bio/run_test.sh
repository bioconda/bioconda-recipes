#!/bin/bash

set -x
set +e

# OS specific tests:
case `uname` in
    Darwin)
	conda inspect objects -p $PREFIX $PKG_NAME  # [osx]
	;;
esac

conda inspect linkages -p $PREFIX $PKG_NAME  # [not win]

# Just check the main binary
arb --help

# Show ARBHOME (debug)
echo "ARBHOME=$ARBHOME"

# Check some basic shell only ARB binaries
echo 'arb_2_ascii $ARBHOME/demo.arb - | arb_2_bin - out.arb' | arb shell

# Check that conda environment is working (ARBHOME set)
arb_2_ascii $ARBHOME/demo.arb - | arb_2_bin - out.arb

# return false for now so the results aren't hidden by Bioconda toolchain
false
