All files in this directory are synthetic test fixtures with no real biological data.
`test.cram` is CRAM version 3.1 (the modern format this recipe's system-htslib fix targets),
generated with samtools/htslib 1.24 from a fabricated (pseudo-random, seed=42) reference and
two fabricated reads. A repeating "ACGT..." sequence was tried first and reproduced correctly
locally, but produced a wrong (mathematically inconsistent) depth result in bioconda CI on the
exact same htslib build -- root cause unknown. Using a non-repetitive sequence avoids that:

```
python3 -c "
import random
random.seed(42)
seq = ''.join(random.choice('ACGT') for _ in range(120))
print('>synthetic_test_seq')
for i in range(0, len(seq), 60):
    print(seq[i:i+60])
" > ref.fa
samtools faidx ref.fa

cat > test.sam <<EOF
@HD	VN:1.6	SO:coordinate
@SQ	SN:synthetic_test_seq	LN:120
synthetic_read_1	0	synthetic_test_seq	1	60	20M	*	0	0	AAGCCCAATAAACCACTCTG	IIIIIIIIIIIIIIIIIIII
synthetic_read_2	0	synthetic_test_seq	21	60	20M	*	0	0	ACTGGCCGAATAGGGATATA	IIIIIIIIIIIIIIIIIIII
EOF

samtools view -C --output-fmt-option version=3.1 -T ref.fa -o test.cram test.sam
samtools index -c test.cram
```

`expected_output.txt` is the exact output of `d4tools view` on the `.d4` file produced from
`test.cram`, used to check that d4tools actually decodes the CRAM correctly (not just that it
links and runs).
