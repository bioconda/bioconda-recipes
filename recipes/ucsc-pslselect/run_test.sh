#!/bin/bash
pslSelect 2> /dev/null || [[ "$?" == 255 ]]
