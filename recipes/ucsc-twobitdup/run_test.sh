#!/bin/bash
twoBitDup 2> /dev/null || [[ "$?" == 255 ]]
