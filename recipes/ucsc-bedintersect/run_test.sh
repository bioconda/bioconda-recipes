#!/bin/bash
bedIntersect 2> /dev/null || [[ "$?" == 255 ]]
