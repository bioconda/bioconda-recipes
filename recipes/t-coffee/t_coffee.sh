#!/bin/sh
set -e

MAX_N_PID_4_TCOFFEE=$(cat /proc/sys/kernel/pid_max)
export MAX_N_PID_4_TCOFFEE
export MCOFFEE_4_TCOFFEE=CHANGEME/mcoffee

"CHANGEME/bin/t_coffee" "$@"
