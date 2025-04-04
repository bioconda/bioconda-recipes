#!/bin/bash
transMapPslToGenePred 2> /dev/null || [[ "$?" == 255 ]]
