#!/bin/bash
bedWeedOverlapping 2> /dev/null || [[ "$?" == 255 ]]
