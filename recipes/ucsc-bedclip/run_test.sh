#!/bin/bash
bedClip 2> /dev/null || [[ "$?" == 255 ]]
