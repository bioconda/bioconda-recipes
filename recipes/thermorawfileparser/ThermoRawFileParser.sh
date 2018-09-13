#/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
mono $DIR/ThermoRawFileParser.exe "$@"
