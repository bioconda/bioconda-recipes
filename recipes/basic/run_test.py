"""Conda-build installed-package smoke test; no checkout or test dependencies."""
from importlib import metadata, resources
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

from basic_assembler import __version__
from basic_assembler.alignment import validate_indexes
from basic_assembler.pipeline import default_database_path


assert metadata.version('basic-immune-assembler') == __version__
reference_root = Path(str(resources.files('basic_assembler.references'))).resolve()
assert reference_root == default_database_path().resolve(), 'Test must use installed package data'
assert (reference_root / 'provenance.json').is_file()
for species in ('human', 'mouse'):
    for receptor in ('BCR', 'TCR'):
        assert len(validate_indexes(reference_root / species / receptor)) == 4
for command in ('basic-assemble', 'BASIC.py', 'basic-references', 'basic-skill', 'bowtie2'):
    assert shutil.which(command), f'Missing executable: {command}'
skill = subprocess.run(['basic-skill', '--print'], check=True, text=True, capture_output=True, timeout=30)
assert len(skill.stdout.strip()) > 100, 'Packaged skill content is missing'

with tempfile.TemporaryDirectory(prefix='basic-conda-test-') as temporary:
    work = Path(temporary)
    reads = work / 'reads.fastq'
    sequence = 'ACTG' * 20
    reads.write_text(f'@smoke\n{sequence}\n+\n' + 'I' * len(sequence) + '\n', encoding='ascii')
    for species in ('human', 'mouse'):
        for receptor in ('BCR', 'TCR'):
            subprocess.run(['basic-assemble', '-SE', str(reads), '-g', species, '-i', receptor,
                            '--check'], cwd=work, check=True, timeout=60)
    subprocess.run(['basic-assemble', '-SE', str(reads), '-a', '-p', '1',
                    '-o', str(work / 'output')], cwd=work, check=True, timeout=120)
    manifest = json.loads((work / 'output' / 'result.run.json').read_text())
    assert manifest['status'] in ('complete', 'partial', 'unsupported')
    assert set(manifest['mapping']) == {'hv', 'hc', 'lv', 'lc'}
    assert manifest['annotation']['status'] == 'not_run'
    for suffix in ('fasta', 'airr.tsv', 'summary.tsv'):
        assert (work / 'output' / f'result.{suffix}').is_file()
print('BASIC installed entrypoints, packaged references, and Bowtie2 smoke test passed')
