#!/bin/bash
faToTab 2> /dev/null || [[ "$?" == 255 ]]
