#!/bin/bash
set -ex

export RUST_BACKTRACE=full

cargo install --verbose --path ./bigtools --root $PREFIX --locked

