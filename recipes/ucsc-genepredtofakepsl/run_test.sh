#!/bin/bash
genePredToFakePsl 2> /dev/null || [[ "$?" == 255 ]]
