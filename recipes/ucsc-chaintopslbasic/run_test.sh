#!/bin/bash
chainToPslBasic 2> /dev/null || [[ "$?" == 255 ]]
