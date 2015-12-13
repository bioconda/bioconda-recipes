#!/bin/bash
pslMap 2> /dev/null || [[ "$?" == 255 ]]
