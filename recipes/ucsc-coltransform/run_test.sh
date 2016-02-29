#!/bin/bash
colTransform 2> /dev/null || [[ "$?" == 255 ]]
