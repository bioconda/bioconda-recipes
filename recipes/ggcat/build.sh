#!/bin/bash -ex

export MACOSX_DEPLOYMENT_TARGET=10.15

cargo install --no-track --verbose --root "${PREFIX}" --path crates/cmdline/ --locked
