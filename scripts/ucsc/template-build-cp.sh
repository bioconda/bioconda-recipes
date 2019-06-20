#!/bin/bash
mkdir -p "$PREFIX/bin"
cp {program_source_dir}/{program} "$PREFIX/bin"
chmod +x "$PREFIX/bin/{program}"
