#!/bin/bash
mafFetch 2> /dev/null || [[ "$?" == 255 ]]
