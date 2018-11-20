#http://superset.apache.org/installation.html

#Ubuntu 16.04 If you have python3.5 installed alongside with python2.7, as is default on Ubuntu 16.04 LTS,
#run this command also:

sudo apt-get install build-essential libssl-dev libffi-dev python3.5-dev python-pip libsasl2-dev libldap2-dev

cd /apps
mkdir superset

cd superset
virtualenv -p `which python3` venv
source ./venv/bin/activate

#Python’s setup tools and pip
#Put all the chances on your side by getting the very latest pip and setuptools libraries.:

pip install --upgrade setuptools pip

#Superset installation and initialization
#Follow these few simple steps to install Superset.:

# Install superset
pip install superset

# Create an admin user (you will be prompted to set a username, first and last name before setting a password)
fabmanager create-admin --app superset

# Initialize the database
superset db upgrade

# Load some data to play with
superset load_examples

# Create default roles and permissions
superset init

# To start a development web server on port 8088, use -p to bind to another port
superset runserver -d