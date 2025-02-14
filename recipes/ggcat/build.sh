#!/bin/bash -ex

cargo install --no-track --verbose --root "${PREFIX}" --path crates/cmdline/ --locked
