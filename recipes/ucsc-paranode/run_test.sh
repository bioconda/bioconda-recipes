#!/bin/bash
paraNode 2> /dev/null || [[ "$?" == 255 ]]
