#!/bin/bash
chainMergeSort 2> /dev/null || [[ "$?" == 255 ]]
