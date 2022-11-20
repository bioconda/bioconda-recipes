#!/bin/bash

gem env
gem install --debug --verbose --backtrace $PKG_NAME -v $PKG_VERSION
