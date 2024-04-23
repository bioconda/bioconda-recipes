#!/bin/bash
chainScore 2> /dev/null || [[ "$?" == 255 ]]
