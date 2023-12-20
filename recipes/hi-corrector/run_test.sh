#!/usr/bin/env bash

set +e
output=$(ic 2>&1)
status=$?
set -e
expected_output="Error: Arguments are insufficient."
expected_status=1

if [ $status -eq $expected_status ] && [[ "$output" == *"$expected_output"* ]]; then
    echo "Tested ic successfully."
else
    printf "Testing ic failed.\nExit code: %s\n%s\n" "$status" "$output" >&2
    exit $status
fi


set +e
output=$(ic_mep --help 2>&1)
status=$?
set -e
expected_output="Usage: ic_mep"
expected_status=1

if [ $status -eq $expected_status ] && [[ "$output" == *"$expected_output"* ]]; then
    echo "Tested ic_mep successfully."
else
    printf "Testing ic_mep failed.\nExit code: %s\n%s\n" "$status" "$output" >&2
    exit $status
fi

set +e
output=$(ic_mes 2>&1)
status=$?
set -e
expected_output="Error: ic_mes arguments are insufficient."
expected_status=1

if [ $status -eq $expected_status ] && [[ "$output" == *"$expected_output"* ]]; then
    echo "Tested ic_mes successfully."
else
    printf "Testing ic_mes failed.\nExit code: %s\n%s\n" "$status" "$output" >&2
    exit $status
fi
