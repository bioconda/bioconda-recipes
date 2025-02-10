#!/usr/bin/env python

import sys
from pathlib import Path

assert(__name__ == "__main__")
this_file = Path(__file__)
this_dir = this_file.parent
if "resolution" in [p.name for p in this_dir.iterdir()]:
    py_dir =this_dir / "resolution"
else:
    py_dir = this_dir.parent / "py" / "resolution"
sys.path.append(str(py_dir.absolute()))
import sequence_graph.path_graph_multik
sequence_graph.path_graph_multik.main()
