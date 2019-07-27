#!/bin/bash
hgGoldGapGl 2> /dev/null || [[ "$?" == 255 ]]
