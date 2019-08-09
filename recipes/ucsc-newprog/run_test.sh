#!/bin/bash
newProg 2> /dev/null || [[ "$?" == 255 ]]
