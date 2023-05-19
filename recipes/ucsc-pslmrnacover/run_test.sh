#!/bin/bash
pslMrnaCover 2> /dev/null || [[ "$?" == 255 ]]
