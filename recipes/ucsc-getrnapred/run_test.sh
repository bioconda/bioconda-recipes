#!/bin/bash
getRnaPred 2> /dev/null || [[ "$?" == 255 ]]
