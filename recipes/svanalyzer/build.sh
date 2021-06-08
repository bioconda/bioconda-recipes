#!/bin/bash

perl Build.PL
perl ./Build
perl ./Build test
perl ./Build install --installdirs site

