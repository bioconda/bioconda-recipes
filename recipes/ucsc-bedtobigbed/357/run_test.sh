#!/bin/bash
bedToBigBed 2> /dev/null || [[ "$?" == 255 ]]
