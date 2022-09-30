#!/bin/bash
crTreeIndexBed 2> /dev/null || [[ "$?" == 255 ]]
