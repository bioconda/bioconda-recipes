#!/bin/bash
pslRecalcMatch 2> /dev/null || [[ "$?" == 255 ]]
