#!/bin/bash
bigMafToMaf 2> /dev/null || [[ "$?" == 255 ]]
