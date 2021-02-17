#!/bin/bash

set -xe

perl Build.PL
perl ./Build
perl ./Build test
perl ./Build install
