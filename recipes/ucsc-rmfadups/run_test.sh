#!/bin/bash
rmFaDups 2> /dev/null || [[ "$?" == 255 ]]
