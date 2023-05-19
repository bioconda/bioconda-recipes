#!/bin/bash
pslToBed 2> /dev/null || [[ "$?" == 255 ]]
