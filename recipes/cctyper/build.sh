${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

DATA_DIR="${SP_DIR}/cctyper/data"

# cctyper 1.9.0 ships the Cas HMM profiles zstd-compressed and decompresses them
# into the database directory on the first run (cctyper/hmmer.py, _iter_hmms).
# That write fails when the environment is read-only (read-only container layers,
# read-only site-packages mounts) and grows the environment by 120 MB at runtime.
# Ship the plain profiles instead - cctyper prefers cctyper_profiles.hmm over the
# .zst, so the compressed copy is not needed and is dropped by --rm.
zstd -q -d --rm "${DATA_DIR}/cctyper_profiles.hmm.zst" -o "${DATA_DIR}/cctyper_profiles.hmm"

# cctyper/data/Profiles.tar.gz is the cctyper 1.8.0 archive of the individual HMM
# profiles (705 files, named the old way). No 1.9.0 code path reads it, all of
# those profiles are contained in the combined cctyper_profiles.hmm shipped above,
# and being an incompressible tarball it is half of the package size.
rm "${DATA_DIR}/Profiles.tar.gz"
