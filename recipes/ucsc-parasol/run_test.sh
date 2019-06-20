#!/bin/bash
parasol 2> /dev/null || [[ "$?" == 255 ]]
