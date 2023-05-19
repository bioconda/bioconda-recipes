#!/bin/bash
netToAxt 2> /dev/null || [[ "$?" == 255 ]]
