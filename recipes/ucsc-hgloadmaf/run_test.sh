#!/bin/bash
hgLoadMaf 2> /dev/null || [[ "$?" == 255 ]]
