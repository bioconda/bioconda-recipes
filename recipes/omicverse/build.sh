#!/bin/sh

poetry build --format wheel
pip install dist/omicverse*.whl