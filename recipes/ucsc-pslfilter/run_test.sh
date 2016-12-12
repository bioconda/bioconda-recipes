#!/bin/bash
pslFilter 2> /dev/null || [[ "$?" == 255 ]]
