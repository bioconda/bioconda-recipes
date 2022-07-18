echo "

================================================================================================================
Phigaro is installed.  You still need to let Phigaro find the necessary paths and download the databases.  
The setup script is phigaro-setup. 
It will download and store about 1.5 Gb for a database to $HOME/.phigaro/ directory. But you can change this directory with a parameter: 
phigaro-setup --pvog NEW_DIR
By default this process demands sudo, but you can waive this behavior by calling:
phigaro-setup --no-updatedb
================================================================================================================
" > $PREFIX/.messages.txt