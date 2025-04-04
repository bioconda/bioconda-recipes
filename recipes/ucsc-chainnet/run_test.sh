#!/bin/bash
chainNet 2> /dev/null || [[ "$?" == 255 ]]
