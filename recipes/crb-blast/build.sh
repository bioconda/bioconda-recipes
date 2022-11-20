#!/bin/bash

gem env
gem install $PKG_NAME -v $PKG_VERSION
head -n 10 $PREFIX/bin/crb-blast
