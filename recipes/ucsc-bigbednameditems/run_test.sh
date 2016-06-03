#!/bin/bash
bigBedNamedItems 2> /dev/null || [[ "$?" == 255 ]]
