#! /bin/bash
set -eu -o pipefail

gem source -a https://rubygems.org/
gem install --install-dir=$PREFIX/lib/ruby/gems/2.2.0 --bindir=$PREFIX/bin arvados-cli-*.gem
