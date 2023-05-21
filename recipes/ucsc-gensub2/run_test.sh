#!/bin/bash
gensub2 2> /dev/null || [[ "$?" == 255 ]]
