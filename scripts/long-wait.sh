#/bin/bash

# Sometimes we need builds to go for longer than the 20 minutes 
# afforded by the stock travis_wait(). This is a custom wrapper based 
# on travis_wait().
# See: https://github.com/travis-ci/travis-ci/issues/1962#issuecomment-34831770

long_wait() {
  local cmd="$@"
  local log_file=long_wait_$$.log

  $cmd 2>&1 >$log_file &
  local cmd_pid=$!

  long_jigger $! $cmd &
  local jigger_pid=$!
  local result

  { wait $cmd_pid 2>/dev/null; result=$?; ps -p$jigger_pid 2>&1>/dev/null && kill $jigger_pid; } || exit 1
  exit $result
}

long_jigger() {
  local timeout=119 # in minutes, just shy of the hard 120 minute cutoff
  local count=0

  local cmd_pid=$1
  shift

  while [ $count -lt $timeout ]; do
    count=$(($count + 1))
    echo -e "\033[0mStill running ($count of $timeout): $@"
    sleep 180
  done

  echo -e "\n\033[31;1mTimeout reached. Terminating $@\033[0m\n"
  kill -9 $cmd_pid
}