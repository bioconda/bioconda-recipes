#!/bin/sh

export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

diamond_add_taxonomy --help |grep DIAMOND_OUTPUT_FILE >/dev/null 2>&1
