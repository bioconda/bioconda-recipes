#!/bin/bash
twoBitToFa 2> /dev/null || [[ "$?" == 255 ]]
