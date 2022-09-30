#!/bin/bash
pslToPslx 2> /dev/null || [[ "$?" == 255 ]]
