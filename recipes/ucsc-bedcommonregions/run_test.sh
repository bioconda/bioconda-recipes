#!/bin/bash
bedCommonRegions 2> /dev/null || [[ "$?" == 255 ]]
