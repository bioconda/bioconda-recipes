#!/bin/bash
bedSort 2> /dev/null || [[ "$?" == 255 ]]
