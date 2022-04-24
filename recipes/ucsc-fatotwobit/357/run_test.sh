#!/bin/bash
faToTwoBit 2> /dev/null || [[ "$?" == 255 ]]
