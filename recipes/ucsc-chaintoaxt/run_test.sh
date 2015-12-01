#!/bin/bash
chainToAxt 2> /dev/null || [[ "$?" == 255 ]]
