#!/bin/bash
bigBedInfo 2> /dev/null || [[ "$?" == 255 ]]
