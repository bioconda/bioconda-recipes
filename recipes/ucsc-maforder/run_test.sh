#!/bin/bash
mafOrder 2> /dev/null || [[ "$?" == 255 ]]
