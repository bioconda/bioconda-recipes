#! /bin/bash
set -eu -o pipefail
gem source -a https://rubygems.org
gem build protk.gemspec
gem env gemdir
gem install --install-dir=$PREFIX/lib/ruby/gems/2.4.0 --bindir=$PREFIX/bin protk -- --with-xml2-lib=$PREFIX/lib --with-xml2-include=$PREFIX/include/libxml2/ --with-opt-include=$PREFIX/include --with-opt-lib=$PREFIX/lib
