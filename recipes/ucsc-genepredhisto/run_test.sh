#!/bin/bash
genePredHisto 2> /dev/null || [[ "$?" == 255 ]]
