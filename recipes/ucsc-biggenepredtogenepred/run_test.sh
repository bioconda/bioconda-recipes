#!/bin/bash
bigGenePredToGenePred 2> /dev/null || [[ "$?" == 255 ]]
