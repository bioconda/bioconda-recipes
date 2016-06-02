#!/bin/bash
faFrag 2> /dev/null || [[ "$?" == 255 ]]
