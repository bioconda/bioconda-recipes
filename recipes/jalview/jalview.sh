#!/usr/bin/env bash

###############################
# Wrapper for Jalview
#
# 2023-08-16 Jalview 2.11.3.0 has new command line arguments
# Old command line arguments are currently detected and actioned
# but are no longer supported and will be removed at a later date.
#
# See
#   Jalview -> Help -> Documentation -> Command Line -> introduction and reference
# or
#   https://www.jalview.org/help/html/features/clarguments.html
# for details of the new command line arguments.
#
# Note, in order to run commandline-only calls use
#   --headless
#
# By default, this wrapper executes java -version to determine the JRE version
# Set JALVIEW_JRE=j1.8 or JALVIEW_JRE=j11 to skip the version check.
#
# By default, this wrapper does NOT restrict the memory consumption of Jalview.
# Set eg. JALVIEW_MAXMEM=1g to set the maximal memory of Jalview's VM
#
# This script is maintained in the Jalview repository in utils/conda/jalview.sh
###############################

declare -a ARGS=("${@}")

# this function is because there's no readlink -f in Darwin/macOS
function readlinkf() {
  FINDFILE="$1"
  FILE="${FINDFILE}"
  PREVFILE=""
  C=0
  MAX=100 # just in case we end up in a loop
  FOUND=0
  while [ "${C}" -lt "${MAX}" -a "${FILE}" != "${PREVFILE}" -a "${FOUND}" -ne 1 ]; do
    PREVFILE="${FILE}"
    FILE="$(readlink "${FILE}")"
    if [ -z "${FILE}" ]; then
      # the readlink is empty means we've arrived at the script, let's canonicalize with pwd
      FILE="$(cd "$(dirname "${PREVFILE}")" &> /dev/null && pwd -P)"/"$(basename "${PREVFILE}")"
      FOUND=1
    elif [ "${FILE#/}" = "${FILE}" ]; then
      # FILE is not an absolute path link, we need to add the relative path to the previous dir
      FILE="$(dirname "${PREVFILE}")/${FILE}"
    fi
    C=$((C+1))
  done
  if [ "${FOUND}" -ne 1 ]; then
    echo "Could not determine path to actual file '$(basename "${FINDFILE}")'" >&2
    exit 1
  fi
  echo "${FILE}"
}

ISMACOS=0
if [ "$( uname -s )" = "Darwin" ]; then
  ISMACOS=1
fi

# check for headless mode
HEADLESS=0
GUI=0
HELP=0
DEBUG=0
for RAWARG in "${@}"; do
  ARG="${RAWARG%%=*}"
  case "${ARG}" in
    --headless|--output|--image|--structureimage)
      HEADLESS=1
      ;;
    --help|--help-*|--version|-h)
      HELP=1
      ;;
    --gui)
      GUI=1
      ;;
    --debug)
      DEBUG=1
      ;;
  esac
  
  if [ "${HELP}" = 1 ]; then
    # --help takes precedence
    HEADLESS=1
    GUI=0
  elif [ "${GUI}" = 1 ]; then
    # --gui takes precedence over --headless
    HEADLESS=0
  fi
done

declare -a JVMARGS=()

# set vars for being inside the macos App Bundle
if [ "${ISMACOS}" = 1 ]; then
# MACOS ONLY
  DIR="$(dirname "$(readlinkf "$0")")"
  if [ -e "${DIR}/jalview_logo.png" ]; then
    JVMARGS=( "${JVMARGS[@]}" "-Xdock:icon=${DIR}/jalview_logo.png" )
  fi
else
# NOT MACOS
  DIR="$(dirname "$(readlink -f "$0")")"
fi

if [ "${HEADLESS}" = 1 ]; then
  # not setting java.awt.headless in java invocation of running jalview due to problem with Jmol
  if [ "${HELP}" = 1 ]; then
    JVMARGS=( "${JVMARGS[@]}" "-Djava.awt.headless=true" )
  fi
  # this suppresses the Java icon appearing in the macOS Dock
  if [ "${ISMACOS}" = 1 ]; then
    JVMARGS=( "${JVMARGS[@]}" "-Dapple.awt.UIElement=true" )
  fi
fi

JAVA=java

# decide which jalview jar to launch - either 'j11' or 'j1.8'
if [[ "$JALVIEW_JRE" != "j11" && "$JALVIEW_JRE" != "j1.8" ]]; then
  JALVIEW_JRE="j11"
  # if java 8 is installed we pick the j1.8 build
  if [[ $( "${JAVA}" -version 2>&1 | grep '"1.8' ) != "" ]]; then
    JALVIEW_JRE="j1.8"
  fi
fi

JARPATH="${DIR}/jalview-all-${JALVIEW_JRE}.jar"

# check if memory maximum is set and if so forward to java-based jalview call
if [ \! -z "$JALVIEW_MAXMEM" ]; then
  JVMARGS=( "${JVMARGS[@]}" "-Xmx${JALVIEW_MAXMEM}" )
fi

# WINDOWS ONLY (Cygwin or WSL)
# change paths for Cygwin or Windows Subsystem for Linux (WSL)
if [ "${ISMACOS}" != 1 ]; then # older macos doesn't like uname -o, best to avoid
  if [ "$(uname -o)" = "Cygwin" ]; then
  # CYGWIN
    JARPATH="$(cygpath -pw "${JARPATH}")"
    # now for some arg paths fun. only translating paths starting with './', '../', '/' or '~'
    ARGS=()
    for ARG in "${@}"; do
      if [ "${ARG}" != "${ARG#@(/|./|../|~)}" ]; then
        ARGS=( "${ARGS[@]}" "$(cygpath -aw "${ARG}")" )
      else
        ARGS=( "${ARGS[@]}" "${ARG}" )
      fi
    done
  elif uname -r | grep -i microsoft | grep -i wsl >/dev/null; then
  # WSL
    JARPATH="$(wslpath -aw "${JARPATH}")"
    ARGS=()
    for ARG in "${@}"; do
      if [ "${ARG}" != "${ARG#@(/|./|../|~)}" ]; then
        # annoyingly wslpath does not work if the file doesn't exist!
        ARGBASENAME="$(basename "${ARG}")"
        ARGDIRNAME="$(dirname "${ARG}")"
        ARGS=( "${ARGS[@]}" "$(wslpath -aw "${ARGDIRNAME}")\\${ARGBASENAME}" )
      else
        ARGS=( "${ARGS[@]}" "${ARG}" )
      fi
    done
    JAVA="${JAVA}.exe"
  fi
fi

# get console width -- three ways to try, just in case
if command -v tput 2>&1 >/dev/null; then
  COLUMNS=$(tput cols) 2>/dev/null
elif command -v stty 2>&1 >/dev/null; then
  COLUMNS=$(stty size | cut -d" " -f2) 2>/dev/null
elif command -v resize 2>&1 >/dev/null; then
  COLUMNS=$(resize -u | grep COLUMNS= | sed -e 's/.*=//;s/;//') 2>/dev/null
fi
JVMARGS=( "${JVMARGS[@]}" "-DCONSOLEWIDTH=${COLUMNS}" )

function quotearray() {
  QUOTEDVALS=""
  for VAL in "${@}"; do
    if [ \! "$QUOTEDVALS" = "" ]; then
      QUOTEDVALS="${QUOTEDVALS} "
    fi
    QUOTEDVALS="${QUOTEDVALS}\"${VAL}\""
  done
  echo $QUOTEDVALS
}

JVMARGSSTR=$(quotearray "${JVMARGS[@]}")
ARGSSTR=$(quotearray "${ARGS[@]}")

if [ "${DEBUG}" = 1 ]; then
 echo Shell running: \""${JAVA}"\" ${JVMARGSSTR} -jar \""${JARPATH}"\" ${ARGSSTR}
fi

"${JAVA}" "${JVMARGS[@]}" -jar "${JARPATH}" "${ARGS[@]}"
