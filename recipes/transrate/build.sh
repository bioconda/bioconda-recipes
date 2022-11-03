#!/bin/bash
set -x
mkdir -p ${PREFIX}/bin
gem build transrate.gemspec
gem install -n ${PREFIX}/bin transrate

# Don't vendor deps like salmon and blast
#ruby ${PREFIX}/bin/transrate --install-deps all

# Clean up the build a bit
rm -f ${PREFIX}/lib/ruby/gems/*/gems/transrate-*/ext/transrate/transrate.o
