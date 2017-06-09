#!/bin/bash

set -ef -o pipefail

wget https://raw.githubusercontent.com/blahah/transrate/master/LICENSE

gem install --install-dir=$PREFIX/lib/ruby/gems/2.1.0 --bindir=$PREFIX/bin transrate

