#!/bin/bash

binny --setup > ${PREFIX}/.binny_setup.txt 2>&1
printf "\nSetting up of CheckM databases, Mantis, and Prokka container completed." >> ${PREFIX}/.messages.txt 2>&1
