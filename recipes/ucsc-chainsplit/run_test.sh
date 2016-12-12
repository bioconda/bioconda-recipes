#!/bin/bash
chainSplit 2> /dev/null || [[ "$?" == 255 ]]
