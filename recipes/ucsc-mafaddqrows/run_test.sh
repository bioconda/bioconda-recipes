#!/bin/bash
mafAddQRows 2> /dev/null || [[ "$?" == 255 ]]
