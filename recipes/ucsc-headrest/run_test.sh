#!/bin/bash
headRest 2> /dev/null || [[ "$?" == 255 ]]
