#!/bin/bash

gem env
gem install --debug --verbose --backtrace --bindir $PREFIX/bin  $PKG_NAME -v $PKG_VERSION
