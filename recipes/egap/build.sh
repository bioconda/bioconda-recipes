#!/usr/bin/env bash
set -eux

mkdir -p "${PREFIX}/bin"

# Install all helper scripts (includes bin/EGAP_TUI.py and the new
# v3.4.x modules: log.py, decontaminate_reads.py, decontaminate_assembly.py,
# file_manager.py, file_operations.py, sample_csv.py, subprocess_runner.py)
cp -r bin/* "${PREFIX}/bin/"

# Keep EGAP.py available as a module for EGAP_TUI.py to import
cp EGAP.py "${PREFIX}/bin/EGAP.py"

# Also install EGAP as the user-facing executable
cp EGAP.py "${PREFIX}/bin/EGAP"

# Provide an extensionless EGAP_TUI command (since tests call EGAP_TUI)
cp "${PREFIX}/bin/EGAP_TUI.py" "${PREFIX}/bin/EGAP_TUI"

chmod +x "${PREFIX}/bin/EGAP" "${PREFIX}/bin/EGAP.py" "${PREFIX}/bin/EGAP_TUI" "${PREFIX}/bin/"*.py
