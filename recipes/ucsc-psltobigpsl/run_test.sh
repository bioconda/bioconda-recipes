#!/bin/bash
pslToBigPsl 2> /dev/null || [[ "$?" == 255 ]]
