#!/bin/bash
set -x
set -e

# Just check the main binary
arb --help

# if we aren't in a conda env, ARBHOME won't be set. Get it.

if [ -z "$CONDA_DEFAULT_ENV" ]; then
    ARBHOME=$(echo 'echo THE_ARB_HOME $ARBHOME' | \
		     arb shell | grep THE_ARB_HOME | cut -f2 -d' ')
    export ARBHOME
elif [ -z "$ARBHOME" ]; then
    source activate $CONDA_DEFAULT_ENV
fi

# Check that ARBHOME exists:
test -d $ARBHOME
echo "ARBHOME=$ARBHOME"

# Check that demo.arb exists
test -r $ARBHOME/demo.arb

# Check arb_2_ascii
arb_2_ascii $ARBHOME/demo.arb - > ascii.arb

# Check arb_2_bin
arb_2_bin ascii.arb demo.arb

