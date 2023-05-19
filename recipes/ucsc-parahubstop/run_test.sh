#!/bin/bash
paraHubStop 2> /dev/null || [[ "$?" == 255 ]]
