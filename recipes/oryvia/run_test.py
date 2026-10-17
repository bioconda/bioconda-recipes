"""Exercise the installed package using only its declared runtime dependencies."""

import hashlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from io import BytesIO
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import threading
import urllib.error
import urllib.parse
import urllib.request
import zipfile

import oryvia_conda as package


def snapshot(root):
    return {str(path.relative_to(root)): (path.stat().st_size, path.stat().st_mtime_ns,
                                        hashlib.sha256(path.read_bytes()).hexdigest())
            for path in root.rglob('*') if path.is_file()}


def check_browser_assets(root, cwd, env):
    """Read-only validation using only the package's declared Python runtime."""
    result = subprocess.run(
        [sys.executable, '-I', '-X', 'utf8', str(root / 'validation/check_browser_assets.py'), '--root', str(root)],
        cwd=cwd, env=env, capture_output=True, text=True, encoding='utf8', timeout=60)
    assert result.returncode == 0, result.stdout[-5000:] + result.stderr[-5000:]
    report = json.loads(result.stdout)
    assert report['status'] == 'PASS' and not report['failures'], report
    assert set(report['versions']) == {'three', 'katex'} and report['font_files_checked'] > 0, report
    assert 'static/index.html' in report['files'], report
    return report


def check_preview_provenance(root, cwd, env):
    result = subprocess.run(
        [sys.executable, '-I', '-X', 'utf8', str(root / 'validation/check_preview_provenance.py'), '--root', str(root)],
        cwd=cwd, env=env, capture_output=True, text=True, encoding='utf8', timeout=60)
    assert result.returncode == 0, result.stdout[-5000:] + result.stderr[-5000:]
    report = json.loads(result.stdout)
    assert report['status'] == 'PASS' and not report['failures'], report
    assert report['checks_performed'] > 0 and report['files_read'] > 0, report
    return report


def main():
    executable = shutil.which('oryvia')
    assert executable, 'The Conda console entry point was not installed.'
    template = package.TEMPLATE
    assert template.is_dir()
    before = snapshot(template)
    assert package.workspace_path().parts[-2:] == ('ORYVIA', package.VERSION)
    assert not (template / '.venv').exists()
    assert not (template / 'static/current_study').exists()
    completed = []
    env = dict(os.environ, ORYVIA_NO_PAUSE='1', HAP_RSCRIPT='/oryvia-test/no-native-Rscript')
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))

    def call(*arguments, success=True, cwd=None):
        result = subprocess.run([executable, *map(str, arguments)], env=env, cwd=cwd,
                                capture_output=True, text=True, encoding='utf8', errors='replace', timeout=240)
        assert (result.returncode == 0) == success, result.stdout[-5000:] + result.stderr[-5000:]
        return result

    def fetch(url, suffix, payload=None, token=None):
        headers = {'Content-Type': 'application/json'} if payload is not None else {}
        if token:
            headers.update({'X-Workstation-Token': token, 'Origin': url})
        request = urllib.request.Request(url + suffix, data=json.dumps(payload).encode() if payload is not None else None,
                                         headers=headers)
        with opener.open(request, timeout=20) as response:
            return response.read()

    call('--help')
    assert package.VERSION in call('--version').stdout
    completed.append('installed help and version')
    with tempfile.TemporaryDirectory(prefix='oryvia conda 测试 ') as directory:
        outside = Path(directory)
        template_assets = check_browser_assets(template, outside, env)
        template_preview = check_preview_provenance(template, outside, env)
        workspace = outside / '研究工作区 with spaces'
        call('init', '--workspace', workspace, cwd=outside)
        assert (workspace / package.MARKER).is_file()
        assert not (workspace / '.venv').exists()
        workspace_assets = check_browser_assets(workspace, outside, env)
        assert workspace_assets == template_assets, 'Workspace browser assets differ from the installed template.'
        completed.append('installed and workspace browser resource closure, versions, licenses and integrity')
        workspace_preview = check_preview_provenance(workspace, outside, env)
        assert workspace_preview == template_preview, 'Workspace preview provenance differs from the installed template.'
        completed.append('installed and workspace scientific preview provenance and source data')
        source_file = workspace / 'server.py'
        original = source_file.read_bytes()
        sentinel = workspace / 'user_notes.txt'
        sentinel.write_text('preserve user content', encoding='utf8')
        call('init', '--workspace', workspace)
        assert sentinel.read_text() == 'preserve user content' and source_file.read_bytes() == original
        completed.append('Unicode workspace and non-destructive repeat initialization')

        occupied = outside / 'existing research'
        occupied.mkdir()
        keep = occupied / 'keep.txt'
        keep.write_text('user data')
        call('init', '--workspace', occupied, success=False)
        assert keep.read_text() == 'user data'
        marker = workspace / package.MARKER
        marker_bytes = marker.read_bytes()
        changed = json.loads(marker_bytes)
        changed['version'] = 'previous-version'
        marker.write_text(json.dumps(changed), encoding='utf8')
        call('init', '--workspace', workspace, success=False)
        marker.write_bytes(marker_bytes)
        call('init', '--workspace', template / 'must-not-write', success=False)
        completed.append('existing data, older version and installation prefix protected')

        linked_workspace = outside / 'linked-workspace'
        try:
            linked_workspace.symlink_to(workspace, target_is_directory=True)
        except OSError:
            if os.name != 'nt':
                raise
        else:
            call('init', '--workspace', linked_workspace, success=False)
            linked_workspace.unlink()
            completed.append('symbolic workspace rejected')

        call('self-test', '--workspace', workspace)
        receipt = json.loads((workspace / 'logs/conda_self_test.json').read_text(encoding='utf8'))
        assert receipt['status'] == 'PASS', receipt
        completed.append('native synthetic computational self-test')

        plot_probe = workspace / 'conda_plot_probe.py'
        plot_probe.write_text('''from pathlib import Path
import json
import xml.etree.ElementTree as ET
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from PIL import Image
from publication_figures import export_figure, publication_rc
output = Path(__file__).parent / "plot_probe_output"
output.mkdir()
with matplotlib.rc_context(publication_rc(["DejaVu Sans"])):
    fig, ax = plt.subplots(figsize=(3, 2))
    ax.errorbar([0.4, -0.2], [0, 1], xerr=[0.1, 0.15], fmt="o")
    ax.set_yticks([0, 1], ["Synthetic A", "Synthetic B"])
    ax.set_xlabel("Effect coefficient")
    fig.tight_layout()
    formats = export_figure(fig, output, "effect", dpi=100, include_tiff=True)
    plt.close(fig)
assert set(formats) == {"png", "svg", "pdf", "tiff"}
for suffix in ("png", "tiff"):
    path = output / ("effect." + suffix)
    with Image.open(path) as image:
        image.verify()
    with Image.open(path) as image:
        assert image.size == (300, 200), image.size
        extrema = image.convert("RGB").getextrema()
        assert all(low < high for low, high in extrema), extrema
assert ET.parse(output / "effect.svg").getroot().tag.endswith("svg")
assert (output / "effect.pdf").read_bytes().startswith(b"%PDF-")
print(json.dumps({"status": "PASS", "matplotlib": matplotlib.__version__, "formats": formats}))
''', encoding='utf8')
        plot_result = subprocess.run(
            [sys.executable, '-I', '-X', 'utf8', str(workspace / 'isolated_entry.py'), plot_probe.name],
            env=env, cwd=workspace, capture_output=True, text=True, encoding='utf8', timeout=120)
        assert plot_result.returncode == 0, plot_result.stdout[-5000:] + plot_result.stderr[-5000:]
        assert json.loads(plot_result.stdout.strip().splitlines()[-1])['status'] == 'PASS'
        completed.append('publication PNG, SVG, PDF and TIFF exports')

        batch_demo = outside / 'batch inputs 测试'
        call('batch', '--workspace', workspace, 'demo', '--directory', batch_demo, cwd=outside)
        manifest = batch_demo / 'tasks.json'
        assert manifest.is_file() and (batch_demo / 'tasks.tsv').is_file()
        inputs_before = snapshot(batch_demo)
        batch_output = batch_demo / 'results'
        relative_manifest = str(manifest.relative_to(outside))
        relative_output = str(batch_output.relative_to(outside))
        run_arguments = ('batch', '--workspace', workspace, 'run', '--manifest', relative_manifest,
                         '--output', relative_output, '--threads', '1')
        call(*run_arguments, '--task-index', '1', cwd=outside)
        association = batch_output / 'tasks/association'
        first_state = json.loads((association / 'status.json').read_text(encoding='utf8'))
        assert first_state['status'] == 'complete' and first_state['exit_code'] == 0
        assert (association / first_state['attempt'] / 'result/result.json').is_file()
        partial = call('batch', '--workspace', workspace, 'summarize', '--manifest', relative_manifest,
                       '--output', relative_output, success=False, cwd=outside)
        assert partial.returncode == 2
        assert json.loads((batch_output / 'summary.json').read_text(encoding='utf8'))['status'] == 'partial'
        resumed = call(*run_arguments, '--task-index', '1', '--resume', cwd=outside)
        assert 'SKIPPED_MATCHED_COMPLETE: association' in resumed.stdout
        assert json.loads((association / 'status.json').read_text(encoding='utf8'))['attempt'] == first_state['attempt']
        call(*run_arguments, '--resume', cwd=outside)
        call('batch', '--workspace', workspace, 'summarize', '--manifest', relative_manifest,
             '--output', relative_output, cwd=outside)
        batch_summary = json.loads((batch_output / 'summary.json').read_text(encoding='utf8'))
        assert batch_summary['status'] == 'complete' and batch_summary['exit_code'] == 0
        assert len(batch_summary['tasks']) == 2 and all(row['status'] == 'complete' for row in batch_summary['tasks'])
        assert len(list((association / 'attempts').iterdir())) == 1
        assert (batch_output / 'summary.tsv').is_file()
        inputs_after = snapshot(batch_demo)
        assert all(inputs_after[name] == original for name, original in inputs_before.items())
        completed.append('real batch calculations, partial status, verified resume and complete summary')

        output_before_templates = snapshot(batch_output)
        for scheduler, directive in (('slurm', '#SBATCH'), ('pbs', '#PBS')):
            script = outside / 'submission templates' / (scheduler + '.sh')
            call('batch', '--workspace', workspace, 'template', '--scheduler', scheduler,
                 '--manifest', relative_manifest, '--output', relative_output, '--script', script,
                 '--threads', '1', cwd=outside)
            text = script.read_text(encoding='utf8')
            assert directive in text and 'hpc_pipeline.py' in text and sys.executable in text
            assert '--task-index' in text
            assert 'export ORYVIA_CONDA_PREFIX=' in text and str(package.INSTALL_PREFIX) in text
        assert snapshot(batch_output) == output_before_templates
        completed.append('Slurm and PBS templates generated without submitting or modifying results')

        blocked = template / 'batch-must-not-write'
        for mode, extra in (
            ('demo', ['--directory', str(blocked)]),
            ('demo', ['--directory=' + str(blocked)]),
            ('run', ['--manifest', str(manifest), '--output', str(blocked)]),
            ('template', ['--scheduler', 'slurm', '--manifest', str(manifest), '--output', str(batch_output),
                          '--script', str(blocked)]),
        ):
            denied = call('batch', '--workspace', workspace, mode, *extra, success=False, cwd=outside)
            assert 'outside the Conda installation' in denied.stderr
            assert not blocked.exists()
        direct_denied = subprocess.run(
            [sys.executable, '-I', '-X', 'utf8', str(workspace / 'isolated_entry.py'),
             'hpc_pipeline.py', 'demo', '--directory', str(blocked)],
            cwd=workspace, env=dict(env, ORYVIA_CONDA_PREFIX=str(package.INSTALL_PREFIX)),
            capture_output=True, text=True, encoding='utf8', timeout=30)
        assert direct_denied.returncode != 0
        assert 'outside the Conda installation' in direct_denied.stderr
        assert not blocked.exists()
        completed.append('batch output cannot modify the Conda installation')

        class ForeignHandler(BaseHTTPRequestHandler):
            def do_GET(self):
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'foreign-listener')
            def log_message(self, *_):
                pass
        listener = ThreadingHTTPServer(('127.0.0.1', 0), ForeignHandler)
        threading.Thread(target=listener.serve_forever, daemon=True).start()
        foreign_url = 'http://127.0.0.1:' + str(listener.server_port)
        state = None
        try:
            call('start', '--workspace', workspace, '--port', listener.server_port, '--no-browser', cwd=outside)
            state = json.loads((workspace / 'launcher_state.json').read_text(encoding='utf8'))
            url = state['url']
            identity = json.loads(fetch(url, '/api/identity'))
            assert identity['application'] == 'ORYVIA' and identity['pid'] == state['pid']
            expected = hashlib.sha256(os.path.normcase(str(workspace.resolve())).encode('utf8')).hexdigest()
            assert identity['project_id'] == expected
            assert url != foreign_url and fetch(foreign_url, '/') == b'foreign-listener'
            assert len(fetch(url, '/')) > 1000
            completed.append('real HTTP server, ownership and occupied-port fallback')

            for relative in workspace_assets['files']:
                assert relative.startswith('static/'), relative
                served = fetch(url, '/' + urllib.parse.quote(relative[len('static/'):], safe='/'))
                expected_bytes = (workspace / relative).read_bytes()
                assert served == expected_bytes, 'HTTP asset differs from the packaged file: ' + relative
            completed.append('HTTP serves every checked browser script, stylesheet, font and icon unchanged')

            repeated = call('start', '--workspace', workspace, '--port', 0, '--no-browser')
            assert 'WORKSTATION_ALREADY_RUNNING=' in repeated.stdout
            assert json.loads((workspace / 'launcher_state.json').read_text(encoding='utf8'))['pid'] == state['pid']
            environment = json.loads((workspace / 'runtime_environment.json').read_text(encoding='utf8'))
            assert environment['python']['selection'] == 'explicit_HAP_PYTHON'
            assert not environment['R']['modules']['mashr']['available']
            completed.append('repeat start and Python-only operation without R')

            bootstrap = json.loads(fetch(url, '/api/bootstrap'))
            demo = json.loads(fetch(url, '/api/demo'))
            assert demo['synthetic']
            imported = json.loads(fetch(url, '/api/import', {'files': demo['files'], 'options': {'hap_encoding': 'binary'}}, bootstrap['token']))
            assert imported.get('dataset_id') and imported.get('preview')
            standard = fetch(url, '/api/standard', {'dataset_id': imported['dataset_id']}, bootstrap['token'])
            with zipfile.ZipFile(BytesIO(standard)) as archive:
                assert archive.testzip() is None and any('phenotype' in name for name in archive.namelist())
            templates = fetch(url, '/api/templates.zip')
            with zipfile.ZipFile(BytesIO(templates)) as archive:
                assert archive.testzip() is None and 'phenotype.tsv' in archive.namelist()
            completed.append('synthetic matrix import and standard/template downloads')
        finally:
            if (workspace / 'launcher_state.json').exists():
                call('stop', '--workspace', workspace)
            listener.shutdown()
            listener.server_close()
        assert not (workspace / 'launcher_state.json').exists()
        if state:
            try:
                fetch(state['url'], '/api/identity')
            except (OSError, urllib.error.URLError):
                pass
            else:
                raise AssertionError('The owned server is still responding after stop.')
        completed.append('verified owned server stopped')
        assert not (workspace / '.venv').exists(), 'No nested environment may be created.'
    assert snapshot(template) == before, 'The installed source template was modified.'
    completed.append('installed source template unchanged')
    print(json.dumps({'status': 'PASS', 'checks': completed,
                      'preview_provenance': {'template': template_preview, 'workspace': workspace_preview}}, indent=2))


if __name__ == '__main__':
    main()
