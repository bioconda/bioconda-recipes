#!/bin/bash
bedToExons 2> /dev/null || [[ "$?" == 255 ]]
