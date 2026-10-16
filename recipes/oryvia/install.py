"""Install the reviewed source as a data template, not as a writable checkout."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import stat
import sysconfig

VERSION = '2026.10.16.1'
recipe = Path(os.environ['RECIPE_DIR'])
source_base = Path(os.environ.get('SRC_DIR', '.')).resolve()
candidates = [source_base, source_base / 'ORYVIA']
source = next((path for path in candidates if (path / 'server.py').is_file() and (path / 'CITATION.cff').is_file()), None)
if source is None:
    raise RuntimeError('The release archive does not contain an ORYVIA source root.')
prefix = Path(os.environ['PREFIX']).resolve()
destination = prefix / 'share' / 'oryvia'
if destination.exists():
    raise RuntimeError('Refusing to replace an existing installed template.')
excluded = {'.git', '.github', '.venv', '__pycache__', '.pytest_cache', '.mypy_cache', '.DS_Store'}
for current, directories, files in os.walk(source, followlinks=False):
    directories[:] = [name for name in directories if name not in excluded]
    for name in directories + files:
        path = Path(current) / name
        if path.is_symlink() or (getattr(path.lstat(), 'st_file_attributes', 0) & getattr(stat, 'FILE_ATTRIBUTE_REPARSE_POINT', 0)):
            raise RuntimeError('Links are not permitted in the source template: ' + str(path.relative_to(source)))
def ignore(_folder, names):
    return [name for name in names if name in excluded or name.endswith(('.pyc', '.pyo'))]
shutil.copytree(source, destination, ignore=ignore)
for forbidden in ('runtime', 'vendor', 'logs', 'runs', 'workspace_data', 'feedback', 'static/current_study',
                  'launcher_state.json', 'connection.json', 'runtime_environment.json'):
    path = destination / forbidden
    if path.is_file() or (path.is_dir() and any(path.iterdir())):
        raise RuntimeError('Generated or private content found in source archive: ' + forbidden)
for required in ('LICENSE', 'THIRD_PARTY_NOTICES.md', 'start_source.py', 'isolated_entry.py', 'static/index.html'):
    if not (destination / required).is_file():
        raise RuntimeError('Required release file is missing: ' + required)
files = {str(path.relative_to(destination)).replace('\\', '/'): hashlib.sha256(path.read_bytes()).hexdigest()
         for path in sorted(destination.rglob('*')) if path.is_file()}
(destination / '.oryvia-template.json').write_text(json.dumps({
    'schema': 'oryvia.conda_template.v1', 'version': VERSION, 'files': files}, indent=2) + '\n', encoding='utf8')
for path in destination.rglob('*'):
    if path.is_file():
        path.chmod(0o444)
site = Path(os.environ.get('SP_DIR', sysconfig.get_path('purelib')))
if not site.resolve().is_relative_to(prefix):
    raise RuntimeError('Python installation location is outside the build prefix.')
site.mkdir(parents=True, exist_ok=True)
shutil.copyfile(recipe / 'oryvia_conda.py', site / 'oryvia_conda.py')
print('Installed ORYVIA template and Conda workspace entry point.')
