#!/bin/bash
bigWigCat 2> /dev/null || [[ "$?" == 255 ]]
