#!/usr/bin/env bash
set -eux

mkdir -p "${PREFIX}/bin"

# Install all helper scripts (includes bin/EGAP_TUI.py)
cp -r bin/* "${PREFIX}/bin/"

# Keep EGAP.py available as a module for EGAP_TUI.py to import
cp EGAP.py "${PREFIX}/bin/EGAP.py"

# Also install EGAP as the user-facing executable
cp EGAP.py "${PREFIX}/bin/EGAP"

# Provide an extensionless EGAP_TUI command (since your tests call EGAP_TUI)
cp "${PREFIX}/bin/EGAP_TUI.py" "${PREFIX}/bin/EGAP_TUI"

chmod +x "${PREFIX}/bin/EGAP" "${PREFIX}/bin/EGAP.py" "${PREFIX}/bin/EGAP_TUI" "${PREFIX}/bin/"*.py
