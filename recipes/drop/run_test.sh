#!/bin/bash
pip install -r tests/requirements.txt
pytest tests/config/ -vv --durations=5
