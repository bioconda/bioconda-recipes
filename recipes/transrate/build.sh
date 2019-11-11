#!/bin/bash
set -x
mkdir -p ${PREFIX}/bin
gem build transrate.gemspec
gem install -n ${PREFIX}/bin transrate
