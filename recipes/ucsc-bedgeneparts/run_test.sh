#!/bin/bash
bedGeneParts 2> /dev/null || [[ "$?" == 255 ]]
