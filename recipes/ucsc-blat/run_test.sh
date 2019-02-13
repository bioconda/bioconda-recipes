#!/bin/bash
blat 2> /dev/null || [[ "$?" == 255 ]]
