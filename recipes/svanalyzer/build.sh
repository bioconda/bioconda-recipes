#!/bin/bash

perl Build.PL
perl ./Build
perl ./Build test DEBUG=1
perl ./Build install --installdirs site

