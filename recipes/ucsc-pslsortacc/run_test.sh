#!/bin/bash
pslSortAcc 2> /dev/null || [[ "$?" == 255 ]]
