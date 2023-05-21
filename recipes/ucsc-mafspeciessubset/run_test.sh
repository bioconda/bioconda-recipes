#!/bin/bash
mafSpeciesSubset 2> /dev/null || [[ "$?" == 255 ]]
