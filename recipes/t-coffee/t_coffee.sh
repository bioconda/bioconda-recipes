#!/bin/sh
set -e

if [[ -f /proc/sys/kernel/pid_max ]] ; then
    MAX_N_PID_4_TCOFFEE=$(cat /proc/sys/kernel/pid_max)
else
    MAX_N_PID_4_TCOFFEE=99998
fi
export MAX_N_PID_4_TCOFFEE
export MCOFFEE_4_TCOFFEE=CHANGEME/mcoffee
# last part of the directory is "linux" on linux and something else otherwise
export PLUGINS_4_TCOFFEE=CHANGEME/plugins/*

exec "CHANGEME/bin/t_coffee" "$@"
