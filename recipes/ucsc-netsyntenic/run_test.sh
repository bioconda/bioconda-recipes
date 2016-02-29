#!/bin/bash
netSyntenic 2> /dev/null || [[ "$?" == 255 ]]
