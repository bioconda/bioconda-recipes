#!/bin/bash
mafToPsl 2> /dev/null || [[ "$?" == 255 ]]
