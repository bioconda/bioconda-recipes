#!/bin/sh
set -e

if [ -f /proc/sys/kernel/pid_max ] ; then
    MAX_N_PID_4_TCOFFEE=$(cat /proc/sys/kernel/pid_max)
else
    MAX_N_PID_4_TCOFFEE=99998
fi
export MAX_N_PID_4_TCOFFEE
export PLUGINS_4_TCOFFEE=CHANGEME/plugins/__OS__
export TEMP='./tmp'
exec "CHANGEME/bin/__OS__/t_coffee" "$@"
