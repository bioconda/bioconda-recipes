import os
import os.path as op

tcoffee_install_path = op.normpath(op.join(op.dirname(__file__), '../../../{{TCOFFEE_FOLDER_NAME}}'))
tcoffee_bin_path = op.join(tcoffee_install_path, 'bin')
tcoffee_exe_file = op.join(tcoffee_bin_path, 't_coffee')
tcoffee_plugins_path = op.join(tcoffee_install_path, 'plugins/linux')
tcoffee_perl_path = op.join(tcoffee_install_path, 'perl/lib/perl5')
tcoffee_default_email = 'username@hostname.com'

def get_tcoffee_environ():
    env = os.environ.copy()
    if ('DIR_4_TCOFFEE' not in env) or (tcoffee_install_path not in env['DIR_4_TCOFFEE']):
        env['DIR_4_TCOFFEE'] = tcoffee_install_path
    if ('MAFFT_BINARIES' not in env) or (tcoffee_plugins_path not in env['MAFFT_BINARIES']):
        env['MAFFT_BINARIES'] = tcoffee_plugins_path
    if ('PERL5LIB' not in env) or (tcoffee_perl_path not in env['PERL5LIB']):
        env['PERL5LIB'] = tcoffee_perl_path + ':' + env.get('PERL5LIB', '')
    if ('EMAIL_4_TCOFFEE' not in env):
        env['EMAIL_4_TCOFFEE'] = tcoffee_default_email
    return env
