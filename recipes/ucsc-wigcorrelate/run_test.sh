#!/bin/bash
wigCorrelate 2> /dev/null || [[ "$?" == 255 ]]
