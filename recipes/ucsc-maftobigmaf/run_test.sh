#!/bin/bash
mafToBigMaf 2> /dev/null || [[ "$?" == 255 ]]
