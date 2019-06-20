#!/bin/bash
hgLoadNet 2> /dev/null || [[ "$?" == 255 ]]
