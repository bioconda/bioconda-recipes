#!/bin/bash
mafSpeciesList 2> /dev/null || [[ "$?" == 255 ]]
