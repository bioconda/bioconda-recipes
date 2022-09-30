#!/bin/bash
faAlign 2> /dev/null || [[ "$?" == 255 ]]
