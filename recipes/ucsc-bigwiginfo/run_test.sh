#!/bin/bash
bigWigInfo 2> /dev/null || [[ "$?" == 255 ]]
