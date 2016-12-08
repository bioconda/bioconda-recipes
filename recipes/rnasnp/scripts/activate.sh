#!/bin/bash
if [[ -z "$RNASNPPATH" ]]; then
	export RNASNPPATH=$CONDA_PREFIX
	export _CONDA_SET_RNASNPPATH=1
fi
