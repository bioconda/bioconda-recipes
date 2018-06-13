#!/bin/bash
mafGene 2> /dev/null || [[ "$?" == 255 ]]
