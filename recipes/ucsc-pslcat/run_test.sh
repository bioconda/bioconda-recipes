#!/bin/bash
pslCat 2> /dev/null || [[ "$?" == 255 ]]
