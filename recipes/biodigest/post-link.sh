#!/bin/bash

echo "Running setup script..." >> "$PREFIX/.messages.txt"
python -c "from biodigest import setup; setup.main(setup_type='api')"
echo "Setup script finished." >> "$PREFIX/.messages.txt"
