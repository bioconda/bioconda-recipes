#!/bin/bash
getRna 2> /dev/null || [[ "$?" == 255 ]]
