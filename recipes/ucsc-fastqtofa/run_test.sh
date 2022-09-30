#!/bin/bash
fastqToFa 2> /dev/null || [[ "$?" == 255 ]]
