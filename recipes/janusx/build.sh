#!/usr/bin/env bash
set -euxo pipefail

# Lower parallelism to reduce peak memory in constrained CI/containers.
export CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-1}"
export CARGO_INCREMENTAL=0
export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-1}"
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_NET_RETRY="${CARGO_NET_RETRY:-6}"
export CARGO_HTTP_TIMEOUT="${CARGO_HTTP_TIMEOUT:-900}"
export CARGO_HTTP_LOW_SPEED_LIMIT="${CARGO_HTTP_LOW_SPEED_LIMIT:-1}"
export CARGO_HTTP_MULTIPLEXING="${CARGO_HTTP_MULTIPLEXING:-false}"
: "${JANUSX_NET_MODE:=auto}"

if [[ "${JANUSX_NET_MODE}" == "direct" ]]; then
  # Force no-proxy direct networking for environments without local proxy.
  unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY || true
  unset http_proxy https_proxy all_proxy no_proxy || true
  unset CARGO_HTTP_PROXY || true
  if [[ -z "${JANUSX_CARGO_REGISTRY:-}" && -z "${JANUSX_CARGO_REGISTRIES:-}" ]]; then
    JANUSX_CARGO_REGISTRIES="sparse+https://index.crates.io/"
  fi
  echo "[build.sh] network mode: direct"
else
  echo "[build.sh] network mode: ${JANUSX_NET_MODE}"
fi

# Reuse git proxy settings automatically when proxy environment variables are
# absent (common on shared HPC login/build nodes).
if [[ "${JANUSX_NET_MODE}" != "direct" && -z "${HTTPS_PROXY:-${https_proxy:-}}" && -z "${HTTP_PROXY:-${http_proxy:-}}" && -z "${ALL_PROXY:-${all_proxy:-}}" ]]; then
  git_proxy="$(git config --global --get https.proxy 2>/dev/null || true)"
  if [[ -z "${git_proxy}" ]]; then
    git_proxy="$(git config --global --get http.proxy 2>/dev/null || true)"
  fi
  if [[ -n "${git_proxy}" ]]; then
    export HTTPS_PROXY="${git_proxy}"
    export HTTP_PROXY="${git_proxy}"
    export https_proxy="${git_proxy}"
    export http_proxy="${git_proxy}"
    if [[ "${git_proxy}" == socks5* || "${git_proxy}" == socks4* ]]; then
      export ALL_PROXY="${git_proxy}"
      export all_proxy="${git_proxy}"
    fi
    echo "[build.sh] bootstrap proxy from git config"
  fi
fi

if [[ "${JANUSX_NET_MODE}" != "direct" && -z "${CARGO_HTTP_PROXY:-}" && -n "${HTTPS_PROXY:-${https_proxy:-}}" ]]; then
  export CARGO_HTTP_PROXY="${HTTPS_PROXY:-${https_proxy:-}}"
fi

# Isolate Cargo config from host/global ~/.cargo to avoid accidental mirror overrides
# (for example stale rsproxy settings on shared HPC nodes).
export HOME="${PWD}/.home"
mkdir -p "${HOME}"
if [[ -n "${JANUSX_CARGO_HOME:-}" ]]; then
  echo "[build.sh] ignore JANUSX_CARGO_HOME=${JANUSX_CARGO_HOME} to keep Cargo config isolated"
fi
export CARGO_HOME="${PWD}/.cargo-home"
mkdir -p "${CARGO_HOME}"
mkdir -p "${PWD}/.cargo"
project_cargo_config="${PWD}/.cargo/config.toml"

# Remove mirror/env overrides inherited from parent shell/session.
unset CARGO_REGISTRIES_CRATES_IO_INDEX || true
unset CARGO_REGISTRIES_CRATES_IO_PROTOCOL || true
unset CARGO_REGISTRIES_CRATES_IO_REPLACE_WITH || true
unset CARGO_SOURCE_CRATES_IO_REPLACE_WITH || true
unset CARGO_REGISTRIES_RSPROXY_INDEX || true

if [[ -d "${PWD}/vendor" ]]; then
  # Project-local config has higher priority than parent-directory ~/.cargo config.
  cat > "${project_cargo_config}" <<EOF
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "${PWD}/vendor"

[net]
git-fetch-with-cli = true
retry = ${CARGO_NET_RETRY}
offline = true
EOF

  cat > "${CARGO_HOME}/config.toml" <<EOF
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "${PWD}/vendor"

[net]
git-fetch-with-cli = true
retry = 6
offline = true
EOF
else
  : "${JANUSX_CARGO_REGISTRIES:=sparse+https://index.crates.io/}"
  : "${JANUSX_CARGO_PROBE:=0}"
  : "${JANUSX_CARGO_PROBE_TIMEOUT:=20}"
  : "${JANUSX_CARGO_PROBE_STRICT:=0}"

  if [[ "${JANUSX_CARGO_PROBE_TIMEOUT}" =~ ^[0-9]+$ ]] && (( JANUSX_CARGO_PROBE_TIMEOUT < 20 )); then
    echo "[build.sh][WARN] JANUSX_CARGO_PROBE_TIMEOUT=${JANUSX_CARGO_PROBE_TIMEOUT} is too small, bump to 20"
    JANUSX_CARGO_PROBE_TIMEOUT=20
  fi

  if [[ -n "${JANUSX_CARGO_REGISTRY:-}" ]]; then
    JANUSX_CARGO_REGISTRIES="${JANUSX_CARGO_REGISTRY} ${JANUSX_CARGO_REGISTRIES}"
  fi

  pick_fallback_registry() {
    local candidate
    if [[ "${JANUSX_NET_MODE}" == "direct" ]]; then
      for candidate in ${JANUSX_CARGO_REGISTRIES}; do
        if [[ "${candidate}" == *"rsproxy.cn"* ]]; then
          echo "${candidate}"
          return
        fi
      done
      for candidate in ${JANUSX_CARGO_REGISTRIES}; do
        if [[ "${candidate}" == *"index.crates.io"* ]]; then
          echo "${candidate}"
          return
        fi
      done
      echo "${JANUSX_CARGO_REGISTRIES%% *}"
      return
    fi

    for candidate in ${JANUSX_CARGO_REGISTRIES}; do
      if [[ "${candidate}" == *"index.crates.io"* ]]; then
        echo "${candidate}"
        return
      fi
    done
    for candidate in ${JANUSX_CARGO_REGISTRIES}; do
      if [[ "${candidate}" == *"rsproxy.cn"* ]]; then
        echo "${candidate}"
        return
      fi
    done
    echo "${JANUSX_CARGO_REGISTRIES%% *}"
  }

  selected_registry=""
  selected_dl=""

  if [[ "${JANUSX_CARGO_PROBE}" == "1" ]]; then
    while IFS= read -r candidate; do
      [[ -n "${candidate}" ]] || continue
      probe_output="$(python - "${candidate}" "${JANUSX_CARGO_PROBE_TIMEOUT}" <<'PY'
import json
import sys
import urllib.request

candidate = sys.argv[1].strip()
timeout = float(sys.argv[2])
index_url = candidate
if index_url.startswith("sparse+"):
    index_url = index_url[len("sparse+"):]
index_url = index_url.rstrip("/")
cfg_url = f"{index_url}/config.json"

try:
    req = urllib.request.Request(cfg_url, headers={"User-Agent": "janusx-cargo-probe/1"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        cfg = json.loads(resp.read().decode("utf-8", errors="replace"))
except Exception:
    raise SystemExit(2)

dl = (cfg.get("dl") or "").rstrip("/")
if not dl:
    raise SystemExit(3)

probe_url = f"{dl}/adler2/2.0.1/download"
try:
    req = urllib.request.Request(
        probe_url,
        headers={"User-Agent": "janusx-cargo-probe/1"},
        method="HEAD",
    )
    with urllib.request.urlopen(req, timeout=timeout):
        pass
except Exception:
    try:
        req = urllib.request.Request(
            probe_url,
            headers={"User-Agent": "janusx-cargo-probe/1"},
        )
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            resp.read(1)
    except Exception:
        raise SystemExit(4)

print(f"OK\t{candidate}\t{dl}")
PY
      )" || {
        echo "[build.sh] skip unreachable cargo registry: ${candidate}"
        continue
      }

      IFS=$'\t' read -r probe_status probe_registry probe_dl <<< "${probe_output}" || true
      if [[ "${probe_status}" == "OK" && -n "${probe_registry}" ]]; then
        selected_registry="${probe_registry}"
        selected_dl="${probe_dl:-}"
        break
      fi
    done < <(printf '%s\n' ${JANUSX_CARGO_REGISTRIES})
  else
    selected_registry="${JANUSX_CARGO_REGISTRY:-${JANUSX_CARGO_REGISTRIES%% *}}"
  fi

  if [[ -z "${selected_registry}" ]]; then
    if [[ "${JANUSX_CARGO_PROBE}" == "1" && "${JANUSX_CARGO_PROBE_STRICT}" == "1" ]]; then
      echo "[build.sh][ERROR] no reachable cargo registry from: ${JANUSX_CARGO_REGISTRIES}"
      echo "[build.sh][ERROR] configure HTTP(S)_PROXY/ALL_PROXY or set JANUSX_CARGO_PROBE_STRICT=0 to force fallback"
      exit 28
    fi
    if [[ "${JANUSX_CARGO_PROBE}" == "1" ]]; then
      echo "[build.sh][WARN] probe found no reachable endpoint within timeout=${JANUSX_CARGO_PROBE_TIMEOUT}s"
      echo "[build.sh][WARN] falling back to preferred registry candidate (set JANUSX_CARGO_PROBE_STRICT=1 to fail-fast)"
    fi
    selected_registry="${JANUSX_CARGO_REGISTRY:-$(pick_fallback_registry)}"
    echo "[build.sh][WARN] probe did not find reachable endpoint; fallback to: ${selected_registry}"
  fi

  JANUSX_CARGO_REGISTRY="${selected_registry}"
  export CARGO_REGISTRIES_CRATES_IO_INDEX="${JANUSX_CARGO_REGISTRY}"

  if [[ "${JANUSX_CARGO_REGISTRY}" == *"index.crates.io"* ]]; then
    # Override any inherited crates-io -> rsproxy replacement explicitly.
    # Use :443 to avoid Cargo's duplicate-source detection on canonical crates-io.
    janusx_direct_registry="sparse+https://index.crates.io:443/"
    cat > "${project_cargo_config}" <<EOF
[source.crates-io]
replace-with = "janusx-registry"

[source.janusx-registry]
registry = "${janusx_direct_registry}"

[net]
git-fetch-with-cli = true
retry = ${CARGO_NET_RETRY}
EOF

    cat > "${CARGO_HOME}/config.toml" <<EOF
[source.crates-io]
replace-with = "janusx-registry"

[source.janusx-registry]
registry = "${janusx_direct_registry}"

[net]
git-fetch-with-cli = true
retry = 6
EOF
  else
    # Explicitly override any parent replace-with (such as rsproxy) by setting
    # crates-io -> janusx-registry at project scope.
    cat > "${project_cargo_config}" <<EOF
[source.crates-io]
replace-with = "janusx-registry"

[source.janusx-registry]
registry = "${JANUSX_CARGO_REGISTRY}"

[net]
git-fetch-with-cli = true
retry = ${CARGO_NET_RETRY}
EOF

    cat > "${CARGO_HOME}/config.toml" <<EOF
[source.crates-io]
replace-with = "janusx-registry"

[source.janusx-registry]
registry = "${JANUSX_CARGO_REGISTRY}"

[net]
git-fetch-with-cli = true
retry = 6
EOF
  fi
fi

echo "[build.sh] cargo: $(cargo --version || true)"
echo "[build.sh] HOME=${HOME}"
echo "[build.sh] CARGO_HOME=${CARGO_HOME}"
echo "[build.sh] JANUSX_NET_MODE=${JANUSX_NET_MODE}"
if [[ -n "${JANUSX_CARGO_REGISTRY:-}" ]]; then
  echo "[build.sh] JANUSX_CARGO_REGISTRY: set"
else
  echo "[build.sh] JANUSX_CARGO_REGISTRY: unset"
fi
if [[ -n "${JANUSX_CARGO_REGISTRIES:-}" ]]; then
  echo "[build.sh] JANUSX_CARGO_REGISTRIES: set"
else
  echo "[build.sh] JANUSX_CARGO_REGISTRIES: unset"
fi
echo "[build.sh] selected registry dl=${selected_dl:-unknown}"
echo "[build.sh] CARGO_HTTP_TIMEOUT=${CARGO_HTTP_TIMEOUT}"
echo "[build.sh] CARGO_HTTP_LOW_SPEED_LIMIT=${CARGO_HTTP_LOW_SPEED_LIMIT}"
echo "[build.sh] CARGO_HTTP_MULTIPLEXING=${CARGO_HTTP_MULTIPLEXING}"
if [[ -n "${CARGO_HTTP_PROXY:-}" ]]; then
  echo "[build.sh] CARGO_HTTP_PROXY: set"
else
  echo "[build.sh] CARGO_HTTP_PROXY: unset"
fi
if [[ -n "${HTTPS_PROXY:-${https_proxy:-}}" ]]; then
  echo "[build.sh] HTTPS proxy: set"
else
  echo "[build.sh] HTTPS proxy: unset"
fi
if [[ -n "${ALL_PROXY:-${all_proxy:-}}" ]]; then
  echo "[build.sh] ALL proxy: set"
else
  echo "[build.sh] ALL proxy: unset"
fi
echo "[build.sh] project cargo config prepared"

# Build/install using the conda-provided maturin + Rust toolchain.
export JANUSX_REQUIRE_OPENBLAS=1
export JANUSX_BUILD_VERBOSE="${JANUSX_BUILD_VERBOSE:-1}"
# v1.0.23 source build can fail to prebuild KMC on some Linux arches due to
# hardcoded `-lz` linking without conda lib search flags. Disable that prebuild
# in recipe build; runtime path can still lazy-build KMC when needed.
export JANUSX_PREBUILD_KMC_BIND=0
if [[ -n "${PREFIX:-}" ]]; then
  export OPENBLAS_LIB_DIR="${PREFIX}/lib"
  export OPENBLAS_INCLUDE_DIR="${PREFIX}/include"
  libdir="${PREFIX}/lib"
  # Compatibility shim for upstream 1.0.23 source on Linux: some builds
  # request `-lopenblas.0`, which resolves to `libopenblas.0.so`.
  # conda-forge commonly ships `libopenblas.so.0` only, so create a local
  # soname alias to keep both x86_64 and aarch64 builds linkable.
  if [[ -d "${libdir}" && ! -e "${libdir}/libopenblas.0.so" ]]; then
    if [[ -e "${libdir}/libopenblas.so.0" ]]; then
      ln -s "libopenblas.so.0" "${libdir}/libopenblas.0.so"
    elif [[ -e "${libdir}/libopenblas.so" ]]; then
      ln -s "libopenblas.so" "${libdir}/libopenblas.0.so"
    fi
  fi
  # Runtime compatibility shim: some OpenBLAS builds expose only
  # libopenblasp-r*.so or libopenblas.so; older JanusX binaries may require
  # libopenblas.so.0 at import time.
  if [[ -d "${libdir}" && ! -e "${libdir}/libopenblas.so.0" ]]; then
    target_basename=""
    for cand in \
      "${libdir}/libopenblasp-r"*.so \
      "${libdir}/libopenblas.so" \
      "${libdir}/libopenblas.so."* \
      "${libdir}/libopenblas"*.so
    do
      if [[ -e "${cand}" && "$(basename "${cand}")" != "libopenblas.so.0" ]]; then
        target_basename="$(basename "${cand}")"
        break
      fi
    done
    if [[ -n "${target_basename}" ]]; then
      ln -s "${target_basename}" "${libdir}/libopenblas.so.0"
    fi
  fi
fi
py_bin="${PYTHON:-python}"
wheel_dir="${PWD}/dist-conda-wheel"
rm -rf "${wheel_dir}"
mkdir -p "${wheel_dir}"

# Build the wheel directly with maturin to avoid opaque pip/PEP517 hook
# failures inside bioconda-utils/conda-build containers.
"${py_bin}" -m maturin build \
  --release \
  --interpreter "${py_bin}" \
  --compatibility off \
  --out "${wheel_dir}" \
  -v

"${py_bin}" -m pip install "${wheel_dir}"/janusx-*.whl \
  --no-deps \
  -vv

# Strict post-build backend gate: fail when Rust backend is not OpenBLAS.
python - <<'PY'
import janusx.janusx as _jx
backend = str(_jx.rust_sgemm_backend())
print(f"[build.sh] rust_sgemm_backend={backend}")
if backend != "openblas":
    raise SystemExit(
        f"Strict mode failed: expected openblas backend, got {backend!r}"
    )
PY

# Collect Rust dependency licenses for Bioconda license compliance checks.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
