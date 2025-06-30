#!/bin/bash
vcfToBed 2> /dev/null || [[ "$?" == 255 ]]
