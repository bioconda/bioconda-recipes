#!/bin/bash
chainToPsl 2> /dev/null || [[ "$?" == 255 ]]
