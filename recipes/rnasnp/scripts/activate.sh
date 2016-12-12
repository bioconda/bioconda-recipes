#!/bin/bash
if [[ -z "$RNASNPPATH" ]]; then
    echo `pwd`
	export RNASNPPATH=`pwd`
	export _CONDA_SET_RNASNPPATH=1
fi
