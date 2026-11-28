#!/usr/bin/env bash
# FitHiChIP_HiCPro.sh changes into its own directory, runs ./src and ./Analysis scripts from there and
# R writes Rplots.pdf into it, so it cannot run from a read-only install (e.g. a container).
# Run a private copy of the code instead; the copy is removed on exit.
set -euo pipefail

share="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../share/@FITHICHIP_SHARE@" && pwd)"
workdir="$(mktemp -d "${TMPDIR:-/tmp}/fithichip.XXXXXX")"
trap 'rm -rf "${workdir}"' EXIT

cp -R "${share}/." "${workdir}/"
bash "${workdir}/FitHiChIP_HiCPro.sh" "$@"
