#!/bin/bash
paraFetch 2> /dev/null || [[ "$?" == 255 ]]
