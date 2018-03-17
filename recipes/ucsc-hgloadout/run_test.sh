#!/bin/bash
hgLoadOut 2> /dev/null || [[ "$?" == 255 ]]
