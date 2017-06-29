#!/bin/bash
hgGcPercent 2> /dev/null || [[ "$?" == 255 ]]
