#!/bin/bash
hubClone 2> /dev/null || [[ "$?" == 255 ]]
