## Postgres 10.6 (upgrade from Postgres 9.5)

0.
# Make a backup. Make sure that your database is not being updated.
pg_dumpall > outputfile

1.
# Create the file /etc/apt/sources.list.d/pgdg.list
> /etc/apt/sources.list.d/pgdg.list

# and add a line for the repository deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main
sudo nano /etc/apt/sources.list.d/pgdg.list
deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main

# Import the repository signing key, and update the package lists
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql-10

2.
# Просматриваем информацию о кластерах:
pg_lsclusters
# stdout>
Ver Cluster Port Status Owner    Data directory               Log file
9.5 main    5432 online postgres /var/lib/postgresql/9.5/main /var/log/postgresql/postgresql-9.5-main.log
10  main    5433 online postgres /var/lib/postgresql/10/main  /var/log/postgresql/postgresql-10-main.log

3.
# Stop cluster 10 main:
sudo pg_dropcluster 10 main --stop

# Check:
pg_lsclusters
# stdout>
Ver Cluster Port Status Owner    Data directory               Log file
9.5 main    5432 online postgres /var/lib/postgresql/9.5/main /var/log/postgresql/postgresql-9.5-main.log

# 10-й кластер остановлен и удален.

4.
# Stop all processes and services writing to the database. Stop the database:
sudo systemctl stop postgresql 

# Check:
pg_lsclusters
# stdout>
Ver Cluster Port Status Owner    Data directory               Log file
9.5 main    5432 'down'   postgres /var/lib/postgresql/9.5/main /var/log/postgresql/postgresql-9.5-main.log

5.
# Upgrade the 9.5 cluster:
sudo pg_upgradecluster -m upgrade 9.5 main
# sudo pg_upgradecluster -m upgrade 10 main

6.
# Run pg_lsclusters. Your 9.6 cluster should now be "down", and the 10 cluster should be online at 5432:
sudo systemctl start postgresql

# Check:
pg_lsclusters
# stdout>
Ver Cluster Port Status Owner    Data directory               Log file
9.5 main    5433 'down'   postgres /var/lib/postgresql/9.5/main /var/log/postgresql/postgresql-9.5-main.log
10  main    5432 'online' postgres /var/lib/postgresql/10/main  /var/log/postgresql/postgresql-10-main.log

7.
# First, check that everything works fine. After that, remove the 9.6 cluster:
sudo pg_dropcluster 9.5 main --stop

# Check:
pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
10  main    5432 online postgres /var/lib/postgresql/10/main /var/log/postgresql/postgresql-10-main.log

# Edit conf:
sudo nano /etc/postgresql/10/main/pg_hba.conf

# Type the options at the end of file
# Replace existing row:
"local  all   flaskdb,ambari,mapred md5"
# to:
local  all   all trust
# And insert new rows:
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust

# reload PostgreSQL
sudo systemctl restart postgresql@10-main

#sudo -u postgres psql
#select pg_reload_conf();
#sudo systemctl restart postgresql@10-main

# Create USER (flaskuser)
sudo -u postgres createuser -D -A -P flaskdb
# password: qwerty

# Create DB (flaskuser)
# sudo -u postgres createdb -O flaskuser flaskdb
sudo -u postgres createdb flaskdb

# Create Linux-user (flaskuser)
root@de3-node1:/home/dataNaut# sudo adduser flaskdb
Adding user 'flaskdb' ...
Adding new group 'flaskdb' (1009) ...
Adding new user 'flaskdb' (1021) with group 'flaskdb' ...
Creating home directory '/home/flaskdb' ...
Copying files from '/etc/skel' ...
Enter new UNIX password: <you_password>
Retype new UNIX password: <you_password>
passwd: password updated successfully
Changing the user information for flaskuser
Enter the new value, or press ENTER for the default
        Full Name []: Flask
        Room Number []:
        Work Phone []:
        Home Phone []:
        Other []:
Is the information correct? [Y/n] Y

#grant all privileges on database flaskdb to flaskuser;

# Connection
sudo -u flaskdb psql

######################################### TESTs ##################################################
create table store (id int, item_name varchar (32), item_price numeric);

insert into store values (1, 'API for checker', 1000);
commit;