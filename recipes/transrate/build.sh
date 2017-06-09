#!/bin/bash

set -ef -o pipefail

gem install --install-dir=$PREFIX/lib/ruby/gems/2.1.0 --bindir=$PREFIX/bin transrate
