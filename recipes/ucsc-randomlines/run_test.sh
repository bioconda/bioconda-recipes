#!/bin/bash
randomLines 2> /dev/null || [[ "$?" == 255 ]]
