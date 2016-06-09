#!/bin/bash
faOneRecord 2> /dev/null || [[ "$?" == 255 ]]
