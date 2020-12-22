#!/bin/bash

CHECKM_ROOT_DIR=$PREFIX/checkm_data
if [[ -d $CHECKM_ROOT_DIR ]]; then
    rm -r $CHECKM_ROOT_DIR
fi
