#!/bin/bash
export LD=$CC
perl Build.PL --extra_compiler_flags "-I$PREFIX/include"
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site
