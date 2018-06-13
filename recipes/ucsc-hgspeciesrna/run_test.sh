#!/bin/bash
hgSpeciesRna 2> /dev/null || [[ "$?" == 255 ]]
