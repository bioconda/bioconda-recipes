#!/bin/bash

perl Build.PL
perl Build
perl Build test
# Make sure this goes in site
perl Build install --installdirs site
