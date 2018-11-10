import os
import os.path as op
import sys
import tempfile

tcoffee_install_dir = op.normpath(op.join(op.dirname(__file__), '..', '..', '..', '{{TCOFFEE_FOLDER_NAME}}'))
tcoffee_bin_dir = op.join(tcoffee_install_dir, 'bin')
tcoffee_exe_file = op.join(tcoffee_bin_dir, 't_coffee')
if sys.platform.startswith('linux'):
    platform = 'linux'
elif sys.platform == 'darwin':
    platform = 'macosx'
else:
    raise Exception("Unsupported platform '%s'" % sys.platform)
tcoffee_plugins_dir = op.join(tcoffee_install_dir, 'plugins', platform)
tcoffee_perl_dir = op.join(tcoffee_install_dir, 'perl', 'lib', 'perl5')
tcoffee_default_email = 'username@example.org'


def get_tcoffee_environ():
    env = os.environ.copy()
    if 'TMP_4_TCOFFEE' not in env:
        env['TMP_4_TCOFFEE'] = tempfile.mkdtemp()
    if 'PLUGINS_4_TCOFFEE' not in env:
        env['PLUGINS_4_TCOFFEE'] = tcoffee_plugins_dir
    if 'MAFFT_BINARIES' not in env:
        env['MAFFT_BINARIES'] = tcoffee_plugins_dir
    if 'PERL5LIB' not in env:
        env['PERL5LIB'] = tcoffee_perl_dir
    elif tcoffee_perl_dir not in env['PERL5LIB']:
        env['PERL5LIB'] = tcoffee_plugins_dir + ':' + env['PERL5LIB']
    if 'EMAIL_4_TCOFFEE' not in env or not env['EMAIL_4_TCOFFEE']:
        env['EMAIL_4_TCOFFEE'] = tcoffee_default_email
    return env
