echo "
ssu-align has been installed.  To run it properly please set the
environment variable SSUALIGNDIR using one the of the following
methods:

Method 1: Temporary (gets reset when you logout)
In your current shell type:

export SSUALIGNDIR=$PREFIX/share/ssu-align-$PKG_VERSION


Method 2: Permanant (persists accross login sessions)
In your ~/.bashrc or ~/.bash_profile (for bash) put this line:

export SSUALIGNDIR=$PREFIX/share/ssu-align-$PKG_VERSION


Advanced: If using conda environments
You can modify the envrionment's activate and deactivate scripts
See here for details:
https://conda.io/docs/user-guide/tasks/manage-environments.html#saving-environment-variables
"
