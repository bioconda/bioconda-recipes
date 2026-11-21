import os
import subprocess
import tempfile
from pathlib import Path

os.environ.pop("PQSIO_LIBRARY", None)
os.environ.pop("PQSIO_BINARY", None)
import pqsio

assert pqsio.__version__ == "0.2.5"
with tempfile.TemporaryDirectory(prefix="pqsio-test-", dir=Path.cwd()) as directory:
    root = Path(directory)
    pairs = root / "pairs.pqs"
    row = pqsio.Pair("read1", 0, 10, 1, 20, "+", "-", 60)
    with pqsio.PairsWriter(pairs, {"chr1": 1000, "chr2": 1000}) as writer:
        writer.write_batch([row])
    with pqsio.PairsReader(pairs) as reader:
        assert [row for batch in reader.iter_batches() for row in batch] == [row]
    subprocess.run(["pqsio", "validate", str(pairs)], check=True)

    concat = root / "concat.pqs"
    fragments = [
        pqsio.Alignment(1, 100, 0, 10, "+", 0, 10, 20, 60, 1.0),
        pqsio.Alignment(1, 100, 20, 30, "-", 1, 20, 30, 60, 1.0),
        pqsio.Alignment(1, 100, 40, 50, "+", 0, 40, 50, 60, 1.0),
    ]
    with pqsio.ConcatWriter(concat, {"chr1": 1000, "chr2": 1000}) as writer:
        writer.write_read(fragments)
    with pqsio.ConcatReader(concat) as reader:
        assert list(reader.iter_reads()) == [fragments]
    expanded = root / "expanded.pqs"
    subprocess.run(["pqsio", "concat2pairs", str(concat), "-o", str(expanded)], check=True)
    with pqsio.PairsReader(expanded) as reader:
        assert len([row for batch in reader.iter_batches() for row in batch]) == 3
print("Python bindings load the installed library without PQSIO_LIBRARY; pairs and concat round trips passed.")
