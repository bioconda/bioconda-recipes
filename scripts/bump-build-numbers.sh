#!/bin/bash
for recipe in $@; do ./bump-build-number.sh $recipe; done
