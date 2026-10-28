"""Run strict upstream parity in Conda's fixture-aware test environment."""

import hashlib
import importlib.metadata
import importlib.util
import json
import platform
import subprocess
import tempfile
from pathlib import Path

import pyarrow.parquet as pq


DATA = Path("tests/data")
EXPECTED_HASHES = {
    "small.bam": "f2133bcedf5c4bbcb72e9440e3b103b83c69ceacb4597dec33e2bf11f6bc8f1c",
    "small.bam.bai": "6a3d9967fc3f738a1e8569ba7361aaa6be07b529115a11e0c536a6f2d8cf25a0",
    "small.bed": "b7020a1509bb8286ecf13670c59df9913bc4ee98172a2b6932d4fb0f9839d223",
    "small.stb": "8daf7802e0f6bd8c8ded6cd45945d15dddf822b61361d4de82c3298da1b2fa17",
    "genes.tsv": "9391bd35b13760ef8869ad7a813b0db97a4f635d8bbb3750b541c6de36ce56ee",
    "null_model.parquet": "992b57b9892a9955c1004a506ea502dec102236eb9fd4b7d9e719fe11e9cd0ae",
    "expected/small_profile.parquet": "3c1c617c1b91b2f3e672017195953706784e583f771ce6d56a0c49680b055d9b",
    "expected/small_gene_stats.parquet": "0e3c8d816beadd9b95a0b7073dfb90d38056b5fb126fa61f40cba55b8baa5b28",
    "expected/small_genome_stats.parquet": "2835f76a9ea367a5bae5e7a0bd45ae85af174979ebd0bebe73b74250bfa18d7d",
}


def emit(label, value):
    print(f"PARITY {label} {json.dumps(value, default=str, sort_keys=True)}", flush=True)


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


emit("environment", {"platform": platform.platform(), **{
    name: importlib.metadata.version(name)
    for name in ("zipstrain", "zipstrain-rust-profiler", "polars", "pyarrow")
}})
for filename, expected_hash in EXPECTED_HASHES.items():
    actual_hash = sha256(DATA / filename)
    emit("input", {"file": filename, "sha256": actual_hash, "expected": expected_hash})
    assert actual_hash == expected_hash, f"Unexpected fixture bytes: {filename}"

null_rows = pq.read_table(DATA / "null_model.parquet").to_pylist()
emit("null-model", {
    "rows": len(null_rows),
    "coverage_min": min(row["cov"] for row in null_rows),
    "coverage_max": max(row["cov"] for row in null_rows),
    "max_error_counts": sorted({row["max_error_count"] for row in null_rows}),
})

original_run = subprocess.run


def traced_run(command, *args, **kwargs):
    if isinstance(command, (list, tuple)) and Path(command[0]).name == "zipstrain-rust-profiler":
        emit("command", command)
        emit("binary", {"path": command[0], "sha256": sha256(Path(command[0]))})
    return original_run(command, *args, **kwargs)


spec = importlib.util.spec_from_file_location("upstream_parity", "tests/test_profile_parity.py")
test = importlib.util.module_from_spec(spec)
spec.loader.exec_module(test)
with tempfile.TemporaryDirectory(prefix="zipstrain-parity-") as output:
    output = Path(output)
    subprocess.run = traced_run
    try:
        test.test_installed_backend_matches_python_fixture(output)
    finally:
        subprocess.run = original_run
        expected = pq.ParquetFile(DATA / "expected/small_profile.parquet")
        actual_file = output / "small_profile.parquet"
        if actual_file.is_file():
            actual = pq.ParquetFile(actual_file)
            for name, file in (("expected", expected), ("actual", actual)):
                emit("metadata", {"profile": name, "values": {
                    k.decode(): v.decode() for k, v in (file.metadata.metadata or {}).items()
                    if k.startswith(b"zipstrain_")
                }})
            want = {(r["chrom"], r["pos"]): r for r in expected.read().to_pylist()}
            got = {(r["chrom"], r["pos"]): r for r in actual.read().to_pylist()}
            differences = [key for key in sorted(want.keys() | got.keys()) if want.get(key) != got.get(key)]
            emit("comparison", {"expected_rows": expected.metadata.num_rows,
                                "actual_rows": actual.metadata.num_rows,
                                "table_equals": actual.read().equals(expected.read()),
                                "different_positions": len(differences)})
            for key in differences[:20]:
                emit("difference", {"chrom": key[0], "pos": key[1],
                                    "expected": want.get(key), "actual": got.get(key)})
emit("result", "All upstream profile and statistics parity assertions passed")
