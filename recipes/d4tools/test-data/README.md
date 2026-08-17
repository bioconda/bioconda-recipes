All files in this directory are synthetic test fixtures with no real biological data.
`test.cram` is CRAM version 3.1 (the modern format this recipe's system-htslib fix targets),
generated with samtools/htslib 1.24 from a fabricated reference and two fabricated reads:

```
cat > ref.fa <<'EOF'
>synthetic_test_seq
ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT
ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT
EOF
samtools faidx ref.fa

cat > test.sam <<'EOF'
@HD	VN:1.6	SO:coordinate
@SQ	SN:synthetic_test_seq	LN:120
synthetic_read_1	0	synthetic_test_seq	1	60	20M	*	0	0	ACGTACGTACGTACGTACGT	IIIIIIIIIIIIIIIIIIII
synthetic_read_2	0	synthetic_test_seq	21	60	20M	*	0	0	ACGTACGTACGTACGTACGT	IIIIIIIIIIIIIIIIIIII
EOF

samtools view -C --output-fmt-option version=3.1 -T ref.fa -o test.cram test.sam
samtools index -c test.cram
```

`expected_output.txt` is the exact output of `d4tools view` on the `.d4` file produced from
`test.cram`, used to check that d4tools actually decodes the CRAM correctly (not just that it
links and runs).
