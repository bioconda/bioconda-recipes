#!/bin/bash
set -eu -o pipefail
export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
gem source -a https://rubygems.org/
gem build *spec
gem install --install-dir=$PREFIX/lib/ruby/gems/2.2.0 --bindir=$PREFIX/bin *.gem
