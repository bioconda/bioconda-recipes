#!/bin/sh

poetry build --format wheel
pip install --no-deps dist/salmid*.whl

