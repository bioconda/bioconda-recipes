#!/bin/bash
splitFile 2> /dev/null || [[ "$?" == 255 ]]
