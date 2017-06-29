#!/bin/bash
oligoMatch 2> /dev/null || [[ "$?" == 255 ]]
