#!/bin/bash
mafFilter 2> /dev/null || [[ "$?" == 255 ]]
