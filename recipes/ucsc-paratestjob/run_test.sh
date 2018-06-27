#!/bin/bash
paraTestJob 2> /dev/null || [[ "$?" == 255 ]]
