#!/bin/bash
pslRc 2> /dev/null || [[ "$?" == 255 ]]
