#!/bin/bash
faSplit 2> /dev/null || [[ "$?" == 255 ]]
