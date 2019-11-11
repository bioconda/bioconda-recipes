#!/bin/bash
set -x
bundle install
bundle exec rake compile
