#!/bin/bash
mafFrag 2> /dev/null || [[ "$?" == 255 ]]
