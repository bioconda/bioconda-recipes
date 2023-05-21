#!/bin/bash
pslReps 2> /dev/null || [[ "$?" == 255 ]]
