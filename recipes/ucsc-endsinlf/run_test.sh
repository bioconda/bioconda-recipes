#!/bin/bash
endsInLf 2> /dev/null || [[ "$?" == 255 ]]
