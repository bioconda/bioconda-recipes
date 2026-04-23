"""
Python 3 compatibility fixes for eKLIPse.
Applied during conda build via build.sh.
"""

import sys

def fix_file(filename, replacements):
    with open(filename) as f:
        content = f.read()
    n = 0
    for old, new in replacements:
        if old in content:
            content = content.replace(old, new)
            n += 1
        else:
            print(f"WARNING [{filename}] pattern not found: {old[:60]}", file=sys.stderr)
    with open(filename, 'w') as f:
        f.write(content)
    print(f"Fixed {n}/{len(replacements)} patterns in {filename}")


# ── Remove 'from string import split' ────────────────────────────────────────
for fname in ['eKLIPse_circos.py', 'eKLIPse_fct.py', 'eKLIPse_sc.py']:
    fix_file(fname, [('from string import split\n', '')])


# ── Replace split(x, sep) with x.split(sep) ──────────────────────────────────
fix_file('eKLIPse_init.py', [
    ('lstLine = split(IN.read(),"\\n")',       'lstLine = IN.read().split("\\n")'),
    ('lst_lines = split(IN.read(),"\\n")',     'lst_lines = IN.read().split("\\n")'),
    ('pathBam = split(lstLine[j],"\\t")[0]',  'pathBam = lstLine[j].split("\\t")[0]'),
    ('titleBam = split(lstLine[j],"\\t")[1]', 'titleBam = lstLine[j].split("\\t")[1]'),
    # nested split(split(...)) on lines 98 and 118
    ("split(split(feature.qualifiers['nomenclature'][0],\"|\")[0],\":\")[1]",
     "feature.qualifiers['nomenclature'][0].split(\"|\")[0].split(\":\")[1]"),
    ('split_line = split(line,"\\t")',         'split_line = line.split("\\t")'),
])

fix_file('eKLIPse_circos.py', [
    ('lst_lines = split(IN.read(),"\\n")', 'lst_lines = IN.read().split("\\n")'),
])

fix_file('eKLIPse_sc.py', [
    ('lst_lines = split(IN.read(),"\\n")', 'lst_lines = IN.read().split("\\n")'),
    ('splitLine = split(line,",")',         'splitLine = line.split(",")'),
    ('splitQread = split(splitLine[0],"_")', 'splitQread = splitLine[0].split("_")'),
    ('start = split(delName,"-")[0]',      'start = delName.split("-")[0]'),
    ('end = split(delName,"-")[1]',        'end = delName.split("-")[1]'),
])


# ── pybam.py: bytes/str and Python 3 iterator fixes ──────────────────────────
fix_file('pybam.py', [
    # is/is not -> ==/!=
    ("code is 'file_alignments_read' or code is 'sam'",
     "code == 'file_alignments_read' or code == 'sam'"),
    ('len(fields) is 0',                   'len(fields) == 0'),
    ("decompressor is not 'internal'",     "decompressor != 'internal'"),
    ("use is not 'internal'",              "use != 'internal'"),
    # magic bytes comparisons
    ("if magic == 'BAM\\1':",              "if magic == b'BAM\\1':"),
    ('elif magic == "\\x1f\\x8b\\x08\\x04":',
     'elif magic == b"\\x1f\\x8b\\x08\\x04":'),
    ('if magic != "\\x1f\\x8b\\x08\\x04":',
     'if magic != b"\\x1f\\x8b\\x08\\x04":'),
    # internal_cache bytes join
    ("yield ''.join(internal_cache)",      "yield b''.join(internal_cache)"),
    # header_cache bytes init and comparison
    ("header_cache = ''",                  "header_cache = b''"),
    ("if header_cache[p_from:p_to] != 'BAM\\1':",
     "if header_cache[p_from:p_to] != b'BAM\\1':"),
    # decode chromosome names to str
    ('self.file_chromosomes.append(header_cache[p_from:p_to -1])',
     'self.file_chromosomes.append(header_cache[p_from:p_to -1].decode("ascii", errors="replace"))'),
    # buffer() -> memoryview()
    ('self.file_binary_header = buffer(header_cache[:p_to])',
     'self.file_binary_header = memoryview(bytes(header_cache[:p_to]))'),
    # file_header decode for split
    ("for line in self.file_header.split('\\n'):",
     "for line in self.file_header.decode('ascii', errors='replace').split('\\n'):"),
    # Python 3 iterator protocol
    ('self.next = next_read',
     'self.next = next_read\n        self.__next__ = next_read'),
    # fix iter to support Python 3 iteration protocol
     ('def __iter__(self): return self',
     'def __iter__(self): return self\n    def __next__(self): return self.next()'),
     # Dynamic parser 
    ('code += "\\n        sam_qname        = self.bam[36            : _end_of_qname -1 ]"',
     'code += "\\n        sam_qname        = self.bam[36            : _end_of_qname -1 ].decode(\'ascii\', errors=\'replace\')"'),
    # Property 
    ('def sam_qname(self):        return               self.bam[ 36                     : self._end_of_qname -1     ]',
    'def sam_qname(self):        return               self.bam[ 36                     : self._end_of_qname -1     ].decode(\'ascii\', errors=\'replace\')'),
    # BAM qname decoding
    ('code += "\\n        sam_qname        = bam_qname[:-1]"',
     'code += "\\n        sam_qname        = bam_qname[:-1].decode(\'ascii\', errors=\'replace\')"'),
])
