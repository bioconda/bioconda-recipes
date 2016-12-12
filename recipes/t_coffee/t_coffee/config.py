import os
import os.path as op

tcoffee_install_dir = op.normpath(op.join(op.dirname(__file__), '..', '..', '..', '{{TCOFFEE_FOLDER_NAME}}'))
tcoffee_bin_dir = op.join(tcoffee_install_dir, 'bin')
tcoffee_exe_file = op.join(tcoffee_bin_dir, 't_coffee')
tcoffee_plugins_dir = op.join(tcoffee_install_dir, 'plugins', 'linux')
tcoffee_perl_dir = op.join(tcoffee_install_dir, 'perl', 'lib', 'perl5')
tcoffee_default_email = 'username@hostname.com'

def get_tcoffee_environ():
    env = os.environ.copy()
    if 'DIR_4_TCOFFEE' not in env:
        env['DIR_4_TCOFFEE'] = tcoffee_install_dir
    elif tcoffee_install_dir not in env['DIR_4_TCOFFEE']:
        env['DIR_4_TCOFFEE'] = env['DIR_4_TCOFFEE'] + ':' + tcoffee_install_dir
    if 'MAFFT_BINARIES' not in env:
        env['MAFFT_BINARIES'] = tcoffee_plugins_dir
    elif tcoffee_plugins_dir not in env['MAFFT_BINARIES']:
        env['MAFFT_BINARIES'] = env['MAFFT_BINARIES'] + ':' + tcoffee_plugins_dir
    if 'PERL5LIB' not in env:
        env['PERL5LIB'] = tcoffee_perl_dir
    elif tcoffee_perl_dir not in env['PERL5LIB']:
        env['PERL5LIB'] = tcoffee_plugins_dir + ':' + env['PERL5LIB'] 
    if 'EMAIL_4_TCOFFEE' not in env or not env['EMAIL_4_TCOFFEE']:
        env['EMAIL_4_TCOFFEE'] = tcoffee_default_email
    return env
