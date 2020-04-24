#!/bin/bash
mafAddIRows 2> /dev/null || [[ "$?" == 255 ]]
