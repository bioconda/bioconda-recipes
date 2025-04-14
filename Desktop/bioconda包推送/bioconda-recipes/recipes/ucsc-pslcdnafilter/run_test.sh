#!/bin/bash
pslCDnaFilter 2> /dev/null || [[ "$?" == 255 ]]
