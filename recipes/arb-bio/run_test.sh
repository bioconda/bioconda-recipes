#!/bin/bash
set -x

# Just check the main binary
arb --help

# Check that ARBHOME exists:
test -d $ARBHOME
echo "ARBHOME=$ARBHOME"

# Check that demo.arb exists
test -r $ARBHOME/demo.arb

# Check arb_2_ascii
arb_2_ascii $ARBHOME/demo.arb - > ascii.arb

# Check arb_2_bin
arb_2_bin ascii.arb demo.arb

