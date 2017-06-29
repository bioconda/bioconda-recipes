#!/bin/bash
validateFiles 2> /dev/null || [[ "$?" == 255 ]]
