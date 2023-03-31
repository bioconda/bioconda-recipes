# Development install

For the latest but not-remotely stable version of the code,
i.e. mostly for team members/collaborators, you will want to 
perform a development install. 

## setup virtual environmnet 

(the directory name and location provided with the second 'venv' argument below may be changed).

```
# create (run once)
python3 -m venv venv
# activate (this should be run once per terminal that one's executing Helixer code from)
source venv/bin/activate
```

## clone and dev install repositories

First `cd` into the directory where you want the repositories, then

```
# GeenuFF (for data management)
git clone https://github.com/weberlab-hhu/GeenuFF
cd GeenuFF/
git checkout dev
pip install -r requirements.txt
pip install -e . 
cd ..

# Helixer (all things DL)
git clone https://github.com/weberlab-hhu/Helixer.git
cd Helixer/
git checkout dev
pip install -r requirements.txt
pip install -e .

# finally, force installation of Geenuff to be 
# the manual one, not the lastest from github main when 
# Helixer was installed
cd ../GeenuFF
pip install -e .
```

That should do it, just don't forget the `source venv/bin/activate` when you 
need to use the code (you could also add this to your .bashrc, if you're not using multiple
virtual environments).

