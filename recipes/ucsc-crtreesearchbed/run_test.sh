#!/bin/bash
crTreeSearchBed 2> /dev/null || [[ "$?" == 255 ]]
