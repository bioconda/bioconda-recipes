#!/bin/bash
if [[ -z "$RNASNPPATH" ]]; then
    if [[ -e ${CONDA_ENV_PATH} ]]; then
        echo CONDA_ENV_PATH ${CONDA_ENV_PATH}
        export RNASNPPATH=${CONDA_ENV_PATH}
        export _CONDA_SET_RNASNPPATH=1
    elif [[ -e ${CONDA_PREFIX} ]]; then
        echo CONDA_PREFIX ${CONDA_PREFIX}
        export RNASNPPATH=${CONDA_PREFIX}
	    export _CONDA_SET_RNASNPPATH=1
    else
        echo "CONDA_PREFIX and CONDA_ENV_PATH are not set"
        exit -1
    fi
fi
