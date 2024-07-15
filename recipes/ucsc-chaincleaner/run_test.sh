#!/bin/bash
chainCleaner 2> /dev/null || [[ "$?" == 255 ]]
