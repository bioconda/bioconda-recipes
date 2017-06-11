#!/bin/bash

set -ef -o pipefail

gem install --install-dir=$PREFIX/lib/ruby/gems/2.2.0 --bindir=$PREFIX/bin transrate
