#!/bin/bash
hubPublicCheck 2> /dev/null || [[ "$?" == 255 ]]
