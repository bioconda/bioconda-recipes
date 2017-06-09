#!/bin/bash

set -ef -o pipefail

gem source -r https://rubygems.org/
gem build transrate.gemspec
gem env gemdir
gem install --install-dir=$PREFIX/lib/ruby/gems/2.1.0 --bindir=$PREFIX/bin transrate
