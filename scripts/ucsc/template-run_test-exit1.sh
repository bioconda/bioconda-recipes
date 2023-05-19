#!/bin/bash
{program} 2> /dev/null || [[ $? == 1 ]]
