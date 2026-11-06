"""Read compressed simpleaf-style files without system HDF5 plugins."""

import os
import subprocess
import sys
import textwrap

import anndata as ad
import h5py
import hdf5plugin
import numpy as np
import pandas as pd
import pytest
from scipy import sparse


@pytest.mark.parametrize("compression", ["blosc", "gzip", None])
@pytest.mark.parametrize("directory_input", [False, True])
def test_compressed_h5ad_input(tmp_path, compression, directory_input):
    quant_dir = tmp_path / "af_quant"
    h5ad_path = quant_dir / "alevin" / "quants.h5ad"
    h5ad_path.parent.mkdir(parents=True)
    counts = sparse.csr_matrix(np.tile([[1, 0, 3], [0, 2, 0]], (128, 1)), dtype=np.float32)
    obs = pd.DataFrame(index=[f"cell-{i}" for i in range(counts.shape[0])])
    obs["barcodes"] = obs.index
    for column in (
        "corrected_reads",
        "mapped_reads",
        "deduplicated_reads",
        "mapping_rate",
        "dedup_rate",
        "mean_by_max",
        "num_genes_expressed",
        "num_genes_over_mean",
    ):
        obs[column] = np.ones(counts.shape[0])
    adata = ad.AnnData(counts, obs=obs)
    adata.layers["spliced"] = counts.copy()
    adata.uns["quant_info"] = '{"usa_mode": true}'
    adata.uns["gpl_info"] = '{"num-passthrough": 256}'
    adata.uns["simpleaf_map_info"] = '{"mapper": "piscem", "cmdline": "piscem -g chromium_v3"}'
    adata.write_h5ad(h5ad_path, compression="gzip" if compression == "blosc" else compression)
    if compression == "blosc":
        # Match anndata-hdf5's writer: Blosc/Zstd for numeric arrays, gzip for
        # strings. Blosc is not suitable for HDF5 variable-length strings.
        with h5py.File(h5ad_path, "r+") as handle:
            numeric_datasets = []
            handle.visititems(
                lambda name, obj: (
                    numeric_datasets.append(name)
                    if isinstance(obj, h5py.Dataset) and obj.dtype.kind in "biuf" and obj.ndim > 0
                    else None
                )
            )
            for name in numeric_datasets:
                data = handle[name][()]
                attrs = dict(handle[name].attrs)
                del handle[name]
                dataset = handle.create_dataset(name, data=data, **hdf5plugin.Blosc(cname="zstd", clevel=5))
                dataset.attrs.update(attrs)
        with h5py.File(h5ad_path) as handle:
            dataset = handle["X/data"]
            assert dataset.id.get_create_plist().get_filter(0)[0] == 32001
            # Verify the filter was actually applied, rather than skipped for a tiny chunk.
            filter_mask, _ = dataset.id.read_direct_chunk((0,))
            assert filter_mask == 0

    # A fresh interpreter is essential: writing the fixture registers filters in
    # this process and would otherwise mask a missing import in QCatch.
    env = os.environ.copy()
    env["HDF5_PLUGIN_PATH"] = str(tmp_path / "missing-plugins")
    result = subprocess.run(
        [
            sys.executable,
            "-c",
            textwrap.dedent("""
            import sys
            import h5py
            import numpy as np

            assert not h5py.h5z.filter_avail(32001)
            from qcatch.utils import get_input

            loaded = get_input(sys.argv[1])
            expected = np.tile([[1, 0, 3], [0, 2, 0]], (128, 1))
            np.testing.assert_array_equal(loaded.mtx_data.X.toarray(), expected)
            np.testing.assert_array_equal(loaded.mtx_data.layers['spliced'].toarray(), expected)
            assert loaded.is_h5ad
            assert loaded.usa_mode
            assert loaded.permit_list_json_data == {'num-passthrough': 256}
            assert loaded.map_json_data['mapper'] == 'piscem'
            assert loaded.feature_dump_data['barcodes'].tolist() == [f'cell-{i}' for i in range(256)]
        """),
            str(quant_dir if directory_input else h5ad_path),
        ],
        env=env,
        capture_output=True,
        check=False,
        text=True,
        timeout=120,
    )
    assert result.returncode == 0, result.stdout + result.stderr
