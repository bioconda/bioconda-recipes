"""ORYVIA Conda entry point: immutable application template, private workspace."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile

VERSION = '2026.10.17.1'
INSTALL_PREFIX = Path(sys.prefix).resolve()
TEMPLATE = INSTALL_PREFIX / 'share' / 'oryvia'
MARKER = '.oryvia-workspace.json'
TEMPLATE_MARKER = '.oryvia-template.json'


def linked(path):
    """Include Windows junctions when this wrapper is tested on Windows."""
    return path.is_symlink() or bool(getattr(path.lstat(), 'st_file_attributes', 0) &
                                     getattr(stat, 'FILE_ATTRIBUTE_REPARSE_POINT', 0))


def assert_plain_tree(root):
    if linked(root):
        raise RuntimeError('Linked application or workspace directories are not supported: ' + str(root))
    for current, directories, files in os.walk(root, followlinks=False):
        for name in directories + files:
            entry = Path(current) / name
            if linked(entry):
                raise RuntimeError('A workspace or template contains a symbolic link: ' + str(entry))


def workspace_path(value=None):
    chosen = Path(value).expanduser().absolute() if value else Path.home() / 'ORYVIA' / VERSION
    # Resolve parent aliases (e.g. macOS /var -> /private/var), but reject a
    # link used as the workspace itself. All descendants are checked separately.
    if chosen.exists() or chosen.is_symlink():
        if linked(chosen):
            raise RuntimeError('Choose a workspace directory, not a symbolic link: ' + str(chosen))
    target = chosen.resolve(strict=False)
    if target == INSTALL_PREFIX or target.is_relative_to(INSTALL_PREFIX) or INSTALL_PREFIX.is_relative_to(target):
        raise RuntimeError('The workspace must be separate from the Conda installation: ' + str(target))
    if target == TEMPLATE or target.is_relative_to(TEMPLATE) or TEMPLATE.is_relative_to(target):
        raise RuntimeError('The installed application template cannot be used as a workspace.')
    return target


def read_marker(path):
    try:
        return json.loads(path.read_text(encoding='utf8'))
    except (OSError, ValueError) as error:
        raise RuntimeError('The workspace marker cannot be read. Choose a new workspace; existing files have not been changed.') from error


def existing_workspace(target):
    if not target.is_dir():
        raise RuntimeError('Workspace is not a directory: ' + str(target))
    assert_plain_tree(target)
    marker = target / MARKER
    if not marker.is_file():
        raise RuntimeError('This nonempty directory is not an ORYVIA Conda workspace. Choose a new empty directory: ' + str(target))
    record = read_marker(marker)
    if record.get('schema') != 'oryvia.conda_workspace.v1' or record.get('version') != VERSION:
        raise RuntimeError('This workspace belongs to another version. Select a new workspace for ORYVIA ' + VERSION + '; existing files have not been changed.')
    for required in ('start_source.py', 'isolated_entry.py', 'server.py', 'stop.py', 'platform_check.py', 'static/index.html'):
        if not (target / required).is_file():
            raise RuntimeError('Workspace application file is missing: ' + required + '. Select a new workspace; existing files have not been changed.')
    return target


def writable_copy(source, destination):
    shutil.copyfile(source, destination)
    os.chmod(destination, 0o644)
    return destination


def initialise(value=None):
    target = workspace_path(value)
    if target.exists():
        if not target.is_dir():
            raise RuntimeError('Workspace path already exists as a file: ' + str(target))
        if any(target.iterdir()):
            return existing_workspace(target)
    if not TEMPLATE.is_dir():
        raise RuntimeError('Installed ORYVIA template is missing. Reinstall the Conda package.')
    assert_plain_tree(TEMPLATE)
    manifest = read_marker(TEMPLATE / TEMPLATE_MARKER)
    if manifest.get('version') != VERSION or manifest.get('schema') != 'oryvia.conda_template.v1':
        raise RuntimeError('Installed template version does not match the Conda entry point.')
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = Path(tempfile.mkdtemp(prefix='.oryvia-init-', dir=target.parent))
    try:
        shutil.copytree(TEMPLATE, temporary, dirs_exist_ok=True, copy_function=writable_copy)
        record = {'schema': 'oryvia.conda_workspace.v1', 'version': VERSION,
                  'created_utc': datetime.now(timezone.utc).isoformat(),
                  'source': 'Conda package ORYVIA ' + VERSION}
        (temporary / MARKER).write_text(json.dumps(record, indent=2) + '\n', encoding='utf8')
        if target.exists():
            # rmdir only removes an empty directory. It cannot remove user data.
            try:
                target.rmdir()
            except OSError:
                return existing_workspace(target)
        try:
            temporary.rename(target)
        except FileExistsError:
            return existing_workspace(target)
    finally:
        # Only remove the uniquely named staging directory created above.
        if temporary.exists() and temporary.parent == target.parent and temporary.name.startswith('.oryvia-init-') and not linked(temporary):
            shutil.rmtree(temporary)
    return target


def environment():
    env = dict(os.environ)
    for name in tuple(env):
        if name.startswith('PYTHON'):
            env.pop(name, None)
    # Preserve the interpreter entry path; resolving a venv/Conda symlink can
    # select the base environment and lose its packages.
    env['HAP_PYTHON'] = sys.executable
    env['ORYVIA_NO_PAUSE'] = '1'
    env['ORYVIA_CONDA_PREFIX'] = str(INSTALL_PREFIX)
    return env


def run_local(root, script, arguments, cwd=None):
    command = [sys.executable, '-I', '-X', 'utf8', str(root / 'isolated_entry.py'), script, *arguments]
    return subprocess.call(command, cwd=cwd or root, env=environment())


def batch_write_path(value):
    chosen = Path(value).expanduser().absolute()
    if (chosen.exists() or chosen.is_symlink()) and linked(chosen):
        raise RuntimeError('Choose a regular batch output path, not a link: ' + str(chosen))
    target = chosen.resolve(strict=False)
    if target == INSTALL_PREFIX or target.is_relative_to(INSTALL_PREFIX):
        raise RuntimeError('Batch output must stay outside the Conda installation: ' + str(target))
    # Inputs may share a parent with outputs. The pipeline validates each file
    # it will write; do not reject or scan unrelated user directory contents.
    return str(target)


def batch_arguments(arguments):
    forwarded = list(arguments)
    if forwarded and forwarded[0] == '--':
        forwarded.pop(0)
    write_options = ('--directory', '--output', '--script')
    for index, value in enumerate(forwarded):
        if value in write_options:
            if index + 1 >= len(forwarded):
                raise RuntimeError('A path is required after ' + value)
            forwarded[index + 1] = batch_write_path(forwarded[index + 1])
        else:
            option, separator, path = value.partition('=')
            if separator and option in write_options:
                if not path:
                    raise RuntimeError('A path is required after ' + option)
                forwarded[index] = option + '=' + batch_write_path(path)
    return forwarded or ['--help']


def parser():
    result = argparse.ArgumentParser(prog='oryvia', description='Local phenotype-genotype association workstation. Analysis files stay in a separate user workspace.')
    result.add_argument('--version', action='version', version='ORYVIA ' + VERSION)
    actions = result.add_subparsers(dest='action', required=True)
    descriptions = {
        'init': 'Create a workspace without changing an existing one.',
        'start': 'Start the browser workstation; create the workspace if needed.',
        'stop': 'Stop only the verified server recorded in this workspace.',
        'check': 'Check native Python calculations and optional tools.',
        'self-test': 'Run small synthetic computational checks.',
        'setup-r': 'Install locked R packages into this workspace; requires native R.',
        'batch': 'Run demo, run, template or summarize through the Linux/HPC batch interface.'}
    for name, description in descriptions.items():
        sub = actions.add_parser(name, help=description, description=description)
        sub.add_argument('--workspace', type=Path, help='Working folder; default: ~/ORYVIA/' + VERSION)
        if name == 'batch':
            sub.add_argument('batch_args', nargs=argparse.REMAINDER, help='Arguments passed to the batch interface.')
        if name == 'start':
            sub.add_argument('--port', type=int, default=8765, help='Local port, or 0 to choose one automatically.')
            sub.add_argument('--no-browser', action='store_true', help='Print the address without opening a browser.')
            sub.add_argument('--foreground', action='store_true', help='Remain attached; Ctrl+C stops this instance.')
        if name in ('check', 'self-test'):
            sub.add_argument('--full', action='store_true', help='Also test optional installed R analysis engines.')
        if name == 'setup-r':
            sub.add_argument('--offline', action='store_true', help='Use previously cached R source packages only.')
    return result


def main(argv=None):
    arguments = list(sys.argv[1:] if argv is None else argv)
    if not sys.flags.isolated:
        # Conda console scripts are normal Python programs. Re-enter without
        # user site/PYTHONPATH before importing application modules.
        return subprocess.call([sys.executable, '-I', '-X', 'utf8', '-c',
                                'from oryvia_conda import main; raise SystemExit(main())', *arguments], env=environment())
    args = parser().parse_args(arguments)
    try:
        if not (3, 12) <= sys.version_info[:2] < (3, 14):
            raise RuntimeError('This package requires Python 3.12 or 3.13.')
        if args.action == 'stop':
            root = existing_workspace(workspace_path(args.workspace))
            return run_local(root, 'stop.py', [])
        if args.action == 'start' and not 0 <= args.port <= 65535:
            raise RuntimeError('Port must be between 0 and 65535.')
        root = initialise(args.workspace)
        print('ORYVIA_WORKSPACE=' + str(root), flush=True)
        if args.action == 'init':
            return 0
        if args.action == 'start':
            extra = ['--port', str(args.port)]
            if args.no_browser:
                extra.append('--no-browser')
            if args.foreground:
                extra.append('--foreground')
            return run_local(root, 'start_source.py', extra)
        if args.action == 'batch':
            return run_local(root, 'hpc_pipeline.py', batch_arguments(args.batch_args), cwd=Path.cwd())
        if args.action == 'setup-r':
            return run_local(root, 'start_source.py', ['--setup-r'] + (['--offline'] if args.offline else []))
        receipt = root / 'logs' / ('conda_' + args.action.replace('-', '_') + '.json')
        return run_local(root, 'platform_check.py', ['--output', str(receipt)] + (['--full'] if args.full else []))
    except (OSError, ValueError, RuntimeError) as error:
        print('ORYVIA_ERROR: ' + str(error), file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        return 130


if __name__ == '__main__':
    raise SystemExit(main())
