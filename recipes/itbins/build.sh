script="$PREFIX"/bin/itbins
echo "#!/usr/bin/env python" > "$script"
cat itBins.py >> "$script"
chmod ugo+x "$script"
