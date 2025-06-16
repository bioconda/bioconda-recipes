#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export GEM_HOME=$PREFIX/share/rubygems
mkdir -p $GEM_HOME
gem build aspera-cli.gemspec
gem install --install-dir $GEM_HOME --bindir $GEM_HOME/bin ${PKG_NAME}-${PKG_VERSION}.gem
gem_path=$GEM_HOME/gems/${PKG_NAME}-${PKG_VERSION}
cp -rf $SRC_DIR/* $gem_path
rm $gem_path/{conda_build,build_env_setup}.sh
tail -n+3 bin/ascli > $gem_path/bin/ascli
tail -n+3 bin/asession > $gem_path/bin/asession

cat << EOF > header.txt
#!/bin/sh
# -*- ruby -*-
_=_\\
=begin
exec "$PREFIX/bin/ruby" "-x" "\$0" "\$@"
=end
#!$PREFIX/bin/ruby
EOF

echo "$(cat header.txt $gem_path/bin/ascli)" > $gem_path/bin/ascli
echo "$(cat header.txt $gem_path/bin/asession)" > $gem_path/bin/asession

ln -sf $gem_path/bin/* $PREFIX/bin

ascli conf ascp install && ascli config ascp info
