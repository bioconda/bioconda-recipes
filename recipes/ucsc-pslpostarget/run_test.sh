#!/bin/bash
pslPosTarget 2> /dev/null || [[ "$?" == 255 ]]
