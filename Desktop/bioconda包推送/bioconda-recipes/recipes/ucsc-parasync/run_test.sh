#!/bin/bash
paraSync 2> /dev/null || [[ "$?" == 255 ]]
