#!/bin/bash
twoBitMask 2> /dev/null || [[ "$?" == 255 ]]
