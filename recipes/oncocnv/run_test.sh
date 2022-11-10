#!/bin/bash

sed -i "s/^TOOLDIR=.*/TOOLDIR=$PREFIX/g" RUNME.sh

bash RUNME.sh
