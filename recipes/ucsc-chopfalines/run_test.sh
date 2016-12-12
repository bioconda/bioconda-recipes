#!/bin/bash
chopFaLines 2> /dev/null || [[ "$?" == 255 ]]
