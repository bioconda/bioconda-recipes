#!/bin/bash
twoBitInfo 2> /dev/null || [[ "$?" == 255 ]]
