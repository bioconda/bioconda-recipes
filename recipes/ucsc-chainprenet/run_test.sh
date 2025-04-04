#!/bin/bash
chainPreNet 2> /dev/null || [[ "$?" == 255 ]]
