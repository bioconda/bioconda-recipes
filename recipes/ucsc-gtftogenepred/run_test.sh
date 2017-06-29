#!/bin/bash
gtfToGenePred 2> /dev/null || [[ "$?" == 255 ]]
