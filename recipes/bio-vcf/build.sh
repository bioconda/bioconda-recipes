#! /bin/bash
set -eu -o pipefail

gem source -r https://rubygems.org/
gem build bio-vcf.gemspec
gem env gemdir
gem install --install-dir=$PREFIX/lib/ruby/gems/2.2.0 --bindir=$PREFIX/bin bio-vcf
