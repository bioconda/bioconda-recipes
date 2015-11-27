#!/bin/bash
mafCoverage 2> /dev/null || [[ "$?" == 255 ]]
