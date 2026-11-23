"""Exercise the installed RabbitAAStore Python package on a tiny FASTA file."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

import aastore


class InstalledPackageTest(unittest.TestCase):
    def test_build_and_read(self):
        names = ["alpha", "empty", "beta", "special", "normalized"]
        descriptions = [
            "caf\u00e9 sample",
            "empty sequence",
            "second protein",
            "ambiguous residues and stop/gap",
            "mixed case and whitespace",
        ]
        sequences = [
            "ACDEFGHIKLMNPQRSTVWY" * 8,
            "",
            "MKTAYIAK" * 12,
            "BZJOUX*-" * 8,
            "ACDEXF-" * 8,
        ]
        inputs = sequences[:-1] + ["ac d\te?f-\n" * 8]
        ids = [3, 0, 3, 1, 4, 2]
        expected = [sequences[i] for i in ids]
        expected_records = [
            {"name": names[i], "description": descriptions[i], "sequence": sequences[i]}
            for i in ids
        ]
        actual_backends = set()
        kernels = set()

        with TemporaryDirectory(prefix="aastore-conda-test-") as temporary:
            root = Path(temporary)
            fasta = root / "input.fasta"
            database = root / "database"
            fasta.write_text(
                "".join(
                    ">{0} {1}\n{2}\n".format(name, description, sequence)
                    for name, description, sequence in zip(names, descriptions, inputs)
                ),
                encoding="utf-8",
            )
            built = aastore.build_fasta(fasta, database, threads=1)
            residues = sum(map(len, sequences))
            self.assertEqual(built.sequences, len(sequences))
            self.assertEqual(built.residues, residues)
            self.assertEqual(built.packed_bytes, (residues * 5 + 7) // 8)

            budgets = [
                (0, aastore.StorageMode.NoMemory),
                (built.packed_bytes // 2, aastore.StorageMode.PartialMemory),
                (built.packed_bytes, aastore.StorageMode.FullMemory),
            ]
            for index_mode in (aastore.IndexLoadMode.Mmap, aastore.IndexLoadMode.Read):
                for resident_text in (False, True):
                    for budget, mode in budgets:
                        with self.subTest(index=index_mode, resident_text=resident_text, mode=mode):
                            opening = aastore.StoreOptions(
                                preload_bytes=budget,
                                threads=1,
                                index_load_mode=index_mode,
                                resident_names=resident_text,
                                resident_descriptions=resident_text,
                            )
                            with aastore.Store(database, opening) as store:
                                self.assertEqual(len(store), len(sequences))
                                self.assertEqual(store.total_residues, residues)
                                self.assertEqual(store.storage_mode, mode)
                                self.assertEqual(store.index_load_mode, index_mode)
                                self.assertEqual(store.resident_bytes, budget)
                                self.assertTrue(store.has_names)
                                self.assertTrue(store.has_descriptions)
                                kernels.add(store.decode_kernel_name)
                                for i, sequence in enumerate(sequences):
                                    self.assertEqual(store.sequence_length(i), len(sequence))
                                    self.assertEqual(store.name_length(i), len(names[i].encode("utf-8")))
                                    self.assertEqual(
                                        store.description_length(i),
                                        len(descriptions[i].encode("utf-8")),
                                    )

                                for backend in (aastore.IoBackend.Auto, aastore.IoBackend.Pread):
                                    with self.subTest(backend=backend):
                                        reads = aastore.ReadOptions(
                                            threads=2,
                                            io_backend=backend,
                                            io_queue_depth=2,
                                            merge_gap_bytes=0,
                                        )
                                        batch = store.get(ids, reads)
                                        self.assertEqual(list(batch), expected)
                                        self.assertEqual(batch.lengths.tolist(), list(map(len, expected)))
                                        self.assertEqual(bytes(batch.view(0)), expected[0].encode("ascii"))
                                        self.assertTrue(batch.view(0).readonly)
                                        self.assertEqual(batch.stats.requested_sequences, len(ids))
                                        if budget == built.packed_bytes:
                                            self.assertEqual(batch.stats.read_bytes, 0)
                                        else:
                                            self.assertGreater(batch.stats.read_bytes, 0)
                                            actual_backends.add("io_uring" if batch.stats.io_uring else "pread")
                                        if backend == aastore.IoBackend.Pread:
                                            self.assertFalse(batch.stats.io_uring)

                                        self.assertEqual(list(store.get(1, reads)), [""])
                                        self.assertEqual(list(store.get([], reads)), [])
                                        consecutive = store.sequential_get(0, len(sequences), reads)
                                        self.assertEqual(list(consecutive), sequences)
                                        self.assertFalse(consecutive.stats.io_uring)
                                        records = store.batch_get_records(ids, options=reads)
                                        self.assertEqual(list(records), expected_records)
                                        text_only = store.batch_get_records(
                                            ids,
                                            aastore.RecordFields.Name | aastore.RecordFields.Description,
                                            reads,
                                        )
                                        self.assertEqual(list(text_only.names), [names[i] for i in ids])
                                        self.assertEqual(
                                            list(text_only.descriptions), [descriptions[i] for i in ids]
                                        )
                                        self.assertEqual(text_only.sequences.stats.requested_sequences, 0)

                                        outputs = [bytearray(len(sequence)) for sequence in expected]
                                        store.get_into(ids, outputs, reads)
                                        self.assertEqual(
                                            [bytes(output).decode("ascii") for output in outputs], expected
                                        )

                            self.assertTrue(store.closed)
                            self.assertEqual(list(batch), expected)
                            self.assertEqual(bytes(batch.view(0)), expected[0].encode("ascii"))
                            self.assertEqual(list(records), expected_records)

        print(
            "RabbitAAStore {0}: build/read checks passed for {1} records ({2} residues); "
            "all residency modes, both index modes, metadata, ordered duplicate requests, "
            "normalization, buffer views and direct output verified. "
            "Kernels: {3}; disk backends observed: {4}.".format(
                aastore.__version__, len(sequences), residues,
                ", ".join(sorted(kernels)), ", ".join(sorted(actual_backends)),
            ),
            flush=True,
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
