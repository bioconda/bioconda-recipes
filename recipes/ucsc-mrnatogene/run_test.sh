#!/bin/bash
mrnaToGene 2> /dev/null || [[ "$?" == 255 ]]
