#!/bin/bash
catUncomment 2> /dev/null || [[ "$?" == 255 ]]
