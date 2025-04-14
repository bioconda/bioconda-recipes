#!/bin/bash
pslPretty 2> /dev/null || [[ "$?" == 255 ]]
