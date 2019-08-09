#!/bin/bash
mafToAxt 2> /dev/null || [[ "$?" == 255 ]]
