#!/bin/bash
pslSort 2> /dev/null || [[ "$?" == 255 ]]
