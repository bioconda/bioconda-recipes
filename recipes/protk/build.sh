#! /bin/bash
set -eu -o pipefail

export LD_LIBRARY_PATH="$PREFIX/lib"

#sed -i.bak "s/s.add_runtime_dependency 'sqlite3'.*/s.add_runtime_dependency 'sqlite3', '~> 1.3'/g" protk.gemspec
cat protk.gemspec
gem source -a https://rubygems.org
gem build protk.gemspec
gem env gemdir
gem install --install-dir=$PREFIX/lib/ruby/gems/2.2.0 --bindir=$PREFIX/bin protk -- --with-xml2-lib=$PREFIX/lib --with-xml2-include=$PREFIX/include/libxml2/ --with-opt-include=$PREFIX/include --with-opt-lib=$PREFIX/lib


