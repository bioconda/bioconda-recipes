#!/bin/bash
rowsToCols 2> /dev/null || [[ "$?" == 255 ]]
