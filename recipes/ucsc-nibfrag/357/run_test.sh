#!/bin/bash
nibFrag 2> /dev/null || [[ "$?" == 255 ]]
