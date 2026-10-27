#!/bin/bash

set -xeuo

cargo install --no-track --verbose --locked --root "${PREFIX}" --path .
