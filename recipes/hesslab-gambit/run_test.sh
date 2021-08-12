#!/bin/bash
set -xe

# Just check command is available
gambit --help

pytest

