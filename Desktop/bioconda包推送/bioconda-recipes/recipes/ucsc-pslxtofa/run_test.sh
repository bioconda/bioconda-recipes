#!/bin/bash
pslxToFa 2> /dev/null || [[ "$?" == 255 ]]
