#!/bin/bash
bedPileUps 2> /dev/null || [[ "$?" == 255 ]]
