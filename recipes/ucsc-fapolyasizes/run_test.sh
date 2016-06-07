#!/bin/bash
faPolyASizes 2> /dev/null || [[ "$?" == 255 ]]
