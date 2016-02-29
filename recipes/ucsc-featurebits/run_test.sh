#!/bin/bash
featureBits 2> /dev/null || [[ "$?" == 255 ]]
