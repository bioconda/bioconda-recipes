#!/bin/bash
mafSplit 2> /dev/null || [[ "$?" == 255 ]]
