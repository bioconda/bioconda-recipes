#!/bin/bash

set -xe

cp -f kent/src/utils/userApps/fetchChromSizes ${{PREFIX}}/bin
chmod 0755 ${{PREFIX}}/bin/fetchChromSizes
