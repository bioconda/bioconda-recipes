#!/bin/bash
chainBridge 2> /dev/null || [[ "$?" == 255 ]]
