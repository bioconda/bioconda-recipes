#!/bin/bash
paraHub 2> /dev/null || [[ "$?" == 255 ]]
