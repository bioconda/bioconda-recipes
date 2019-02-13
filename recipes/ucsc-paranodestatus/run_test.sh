#!/bin/bash
paraNodeStatus 2> /dev/null || [[ "$?" == 255 ]]
