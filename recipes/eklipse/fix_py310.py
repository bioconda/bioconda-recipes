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


for fname in ['eKLIPse_circos.py', 'eKLIPse_fct.py', 'eKLIPse_sc.py']:
    fix_file(fname, [('from string import split\n', '')])

fix_file('eKLIPse_init.py', [
    ('lstLine = split(IN.read(),"\\n")',       'lstLine = IN.read().split("\\n")'),
    ('lst_lines = split(IN.read(),"\\n")',     'lst_lines = IN.read().split("\\n")'),
    ('pathBam = split(lstLine[j],"\\t")[0]',  'pathBam = lstLine[j].split("\\t")[0]'),
    ('titleBam = split(lstLine[j],"\\t")[1]', 'titleBam = lstLine[j].split("\\t")[1]'),
    ("split(split(feature.qualifiers['nomenclature'][0],\"|\")[0],\":\")[1]",
     "feature.qualifiers['nomenclature'][0].split(\"|\")[0].split(\":\")[1]"),
    ('split_line = split(line,"\\t")',         'split_line = line.split("\\t")'),
])

fix_file('eKLIPse_circos.py', [
    ('lst_lines = split(IN.read(),"\\n")', 'lst_lines = IN.read().split("\\n")'),
    ('start = int(split(key,"-")[0])',     'start = int(key.split("-")[0])'),
    ('end = int(split(key,"-")[1])',       'end = int(key.split("-")[1])'),
])

fix_file('eKLIPse_sc.py', [
    ('lst_lines = split(IN.read(),"\\n")', 'lst_lines = IN.read().split("\\n")'),
    ('splitLine = split(line,",")',         'splitLine = line.split(",")'),
    ('splitQread = split(splitLine[0],"_")', 'splitQread = splitLine[0].split("_")'),
    ('start = split(delName,"-")[0]',      'start = delName.split("-")[0]'),
    ('end = split(delName,"-")[1]',        'end = delName.split("-")[1]'),
    ("JSON = open(pathSCjson,'wb')", "JSON = open(pathSCjson,'w')"),
    ("JSON = open(pathBLASTjson,'wb')", "JSON = open(pathBLASTjson,'w')"),
    ("JSON = open(pathCumuljson,'wb')", "JSON = open(pathCumuljson,'w')"),
    ('start = int(split(delName,"-")[0])', 'start = int(delName.split("-")[0])'),
    ('end = int(split(delName,"-")[1])',   'end = int(delName.split("-")[1])'),
    ('start2 = int(split(delName2,"-")[0])', 'start2 = int(delName2.split("-")[0])'),
    ('end2 = int(split(delName2,"-")[1])',   'end2 = int(delName2.split("-")[1])'),
    ('start = int(split(delPos,"-")[0])',    'start = int(delPos.split("-")[0])'),
    ('end = int(split(delPos,"-")[1])',      'end = int(delPos.split("-")[1])'),
    ('start = int(split(deletion,"-")[0])', 'start = int(deletion.split("-")[0])'),
    ('end = int(split(deletion,"-")[1])',   'end = int(deletion.split("-")[1])'),
    ("dicoBam[str(i)]['nb_sc_reads_F']", "dicoBam[i]['nb_sc_reads_F']"),
    ("dicoBam[str(i)]['nb_sc_fasta_F']", "dicoBam[i]['nb_sc_fasta_F']"),
    ("dicoBam[str(i)]['nb_sc_reads_R']", "dicoBam[i]['nb_sc_reads_R']"),
    ("dicoBam[str(i)]['nb_sc_fasta_R']", "dicoBam[i]['nb_sc_fasta_R']"),
    ("dicoBam[str(max_occ_start)]['nb_reads_F']", "dicoBam[max_occ_start]['nb_reads_F']"),
    ("dicoBam[str(max_occ_end)]['nb_reads_R']",   "dicoBam[max_occ_end]['nb_reads_R']"),
])


fix_file('pybam.py', [
    ("code is 'file_alignments_read' or code is 'sam'",
     "code == 'file_alignments_read' or code == 'sam'"),
    ('len(fields) is 0',                   'len(fields) == 0'),
    ("decompressor is not 'internal'",     "decompressor != 'internal'"),
    ("use is not 'internal'",              "use != 'internal'"),
    ("if magic == 'BAM\\1':",              "if magic == b'BAM\\1':"),
    ('elif magic == "\\x1f\\x8b\\x08\\x04":',
     'elif magic == b"\\x1f\\x8b\\x08\\x04":'),
    ('if magic != "\\x1f\\x8b\\x08\\x04":',
     'if magic != b"\\x1f\\x8b\\x08\\x04":'),
    ("yield ''.join(internal_cache)",      "yield b''.join(internal_cache)"),
    ("header_cache = ''",                  "header_cache = b''"),
    ("if header_cache[p_from:p_to] != 'BAM\\1':",
     "if header_cache[p_from:p_to] != b'BAM\\1':"),
    ('self.file_chromosomes.append(header_cache[p_from:p_to -1])',
     'self.file_chromosomes.append(header_cache[p_from:p_to -1].decode("ascii", errors="replace"))'),
    ('self.file_binary_header = buffer(header_cache[:p_to])',
     'self.file_binary_header = memoryview(bytes(header_cache[:p_to]))'),
    ("for line in self.file_header.split('\\n'):",
     "for line in self.file_header.decode('ascii', errors='replace').split('\\n'):"),
    ('self.next = next_read',
     'self.next = next_read\n        self.__next__ = next_read'),
     ('def __iter__(self): return self',
     'def __iter__(self): return self\n    def __next__(self): return self.next()'),
    ('code += "\\n        sam_qname        = self.bam[36            : _end_of_qname -1 ]"',
     'code += "\\n        sam_qname        = self.bam[36            : _end_of_qname -1 ].decode(\'ascii\', errors=\'replace\')"'),
    ('def sam_qname(self):        return               self.bam[ 36                     : self._end_of_qname -1     ]',
    'def sam_qname(self):        return               self.bam[ 36                     : self._end_of_qname -1     ].decode(\'ascii\', errors=\'replace\')'),
    ('code += "\\n        sam_qname        = bam_qname[:-1]"',
     'code += "\\n        sam_qname        = bam_qname[:-1].decode(\'ascii\', errors=\'replace\')"'),
     ('raise StopIteration', 'return'),
])


fix_file('eKLIPse_fct.py', [
    ("""def load_json(path):
    # Read json file
    json_data=open(path)
    data = json.load(json_data)
    json_data.close()
    return byteify(data)""",
     """def load_json(path):
    # Read json file
    json_data=open(path)
    data = json.load(json_data, object_pairs_hook=lambda pairs: {int(k) if k.lstrip('-').isdigit() else k: v for k, v in pairs})
    json_data.close()
    return data"""),
    ('if str(pos) in dicoMean: ToWrite = "hsM\\t"+str(pos)+"\\t"+str(pos+1)+"\\t"+str(float(dicoMean[str(pos)])/float(nb_sample))+"\\n"',
    'if pos in dicoMean: ToWrite = "hsM\\t"+str(pos)+"\\t"+str(pos+1)+"\\t"+str(float(dicoMean[pos])/float(nb_sample))+"\\n"'),
])
