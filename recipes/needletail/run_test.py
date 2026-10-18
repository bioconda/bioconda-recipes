import unittest

from needletail import (
    parse_fastx_file,
    parse_fastx_string,
    NeedletailError,
    reverse_complement,
    normalize_seq,
)


FASTA_FILE, FASTQ_FILE = "test.fa", "test.fq"


class ParsingTestCase(unittest.TestCase):
    def get_fasta_reader(self):
        return parse_fastx_file(FASTA_FILE)

    def get_fastq_reader(self):
        return parse_fastx_file(FASTQ_FILE)

    def test_can_parse_fasta_file(self):
        for i, record in enumerate(self.get_fasta_reader()):
            if i == 0:
                self.assertEqual(record.id, "test")
                self.assertEqual(record.seq, "AGCTGATCGA")
                self.assertIsNone(record.qual)
                record.normalize(iupac=False)
                self.assertEqual(record.seq, "AGCTGATCGA")
                self.assertTrue(record.is_fasta())
            if i == 1:
                self.assertEqual(record.id, "test2")
                self.assertEqual(record.seq, "TAGC")
                self.assertIsNone(record.qual)
                record.normalize(iupac=False)
                self.assertEqual(record.seq, "TAGC")
                self.assertTrue(record.is_fasta())

            self.assertTrue(i <= 1)

    def test_can_parse_fastq_file(self):
        for i, record in enumerate(self.get_fastq_reader()):
            if i == 0:
                self.assertEqual(record.id, "EAS54_6_R1_2_1_413_324")
                self.assertEqual(record.seq, "CCCTTCTTGTCTTCAGCGTTTCTCC")
                self.assertEqual(record.qual, ";;3;;;;;;;;;;;;7;;;;;;;88")
                record.normalize(iupac=False)
                self.assertEqual(record.seq, "CCCTTCTTGTCTTCAGCGTTTCTCC")
                self.assertTrue(record.is_fastq())
            if i == 1:
                self.assertEqual(record.id, "EAS54_6_R1_2_1_540_792")
                self.assertEqual(record.seq, "TTGGCAGGCCAAGGCCGATGGATCA")
                self.assertEqual(record.qual, ";;;;;;;;;;;7;;;;;-;;;3;83")
                record.normalize(iupac=False)
                self.assertEqual(record.seq, "TTGGCAGGCCAAGGCCGATGGATCA")
                self.assertTrue(record.is_fastq())

            self.assertTrue(i <= 2)


class ParsingStrTestCase(ParsingTestCase):
    def get_fasta_reader(self):
        with open(FASTA_FILE) as f:
            content = f.read()
            return parse_fastx_string(content)

    def get_fastq_reader(self):
        with open(FASTQ_FILE) as f:
            content = f.read()
            return parse_fastx_string(content)


class MiscelleanousTestCase(unittest.TestCase):
    def test_normalize_seq(self):
        self.assertEqual(normalize_seq("ACGTU", iupac=False), "ACGTT")
        self.assertEqual(normalize_seq("acgtu", iupac=False), "ACGTT")
        self.assertEqual(normalize_seq("N.N-N~N N", iupac=False), "N-N-N-NN")
        self.assertEqual(normalize_seq("BDHVRYSWKM", iupac=True), "BDHVRYSWKM")
        self.assertEqual(normalize_seq("bdhvryswkm", iupac=True), "BDHVRYSWKM")

    def test_reverse_complement(self):
        self.assertEqual(reverse_complement("a"), "t")
        self.assertEqual(reverse_complement("c"), "g")
        self.assertEqual(reverse_complement("g"), "c")
        self.assertEqual(reverse_complement("n"), "n")

        self.assertEqual(reverse_complement("atcg"), "cgat")


class ErroringTestCase(unittest.TestCase):
    def test_file_not_found(self):
        with self.assertRaises(NeedletailError):
            parse_fastx_file("hey")

    def test_invalid_record(self):
        with self.assertRaises(NeedletailError):
            for i, record in enumerate(parse_fastx_string("Not a valid file")):
                print(i)


if __name__ == "__main__":
    unittest.main()
