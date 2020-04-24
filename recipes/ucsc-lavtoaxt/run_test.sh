#!/bin/bash
lavToAxt 2> /dev/null || [[ "$?" == 255 ]]
