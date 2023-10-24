#!/usr/bin/env bash

gem_path=$PREFIX/${PKG_NAME}-${PKG_VERSION}
mkdir -p $gem_path
cp -r $SRC_DIR/* $gem_path
rm $gem_path/{conda_build,build_env_setup}.sh

gem build aspera-cli.gemspec
gem install ${PKG_NAME}-${PKG_VERSION}.gem

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
mv $gem_path $PREFIX/share/rubygems/gems
ln -s $PREFIX/share/rubygems/gems/${PKG_NAME}-${PKG_VERSION}/bin/* $PREFIX/bin

export ASCLI_HOME="$PREFIX/etc/aspera"
ascli conf ascp install && ascli config ascp info 
cp $ASCLI_HOME/aspera-license .
ln -s $ASCLI_HOME/{ascp,aspera-license} $PREFIX/bin
