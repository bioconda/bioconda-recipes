#!/bin/bash
faToVcf 2> /dev/null || [[ "$?" == 1 ]]
