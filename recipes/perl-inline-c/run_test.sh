#!/bin/bash
export PERL_INLINE_DIRECTORY=/tmp/ &&  \
env && \
ls -l /usr/local/bin && \
perl -e 'print $ENV{"_"};' && \
perl -e 'use Inline C=>q{void greet(){printf("Hello, world\n");}};greet'
