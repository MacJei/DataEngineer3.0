############################################# Ambari:
apt-get update

############################################# Divolte HOME:
cd /apps/divolte/divolte-collector-0.9.0
# Start  divolte:
./bin/divolte-collector

# Check divolte:
http://35.204.145.90:8290/#/fragment/path?q=textual&n=42

############################################# Postgres:
cat /etc/apt/sources.list.d/pgdg.list
sudo systemctl restart postgresql@10-main

############################################# Flask:
cd /apps/flask
# Install venv
virtualenv -p `which python3` flask
New python executable in flask/bin/python
Installing setuptools............................done.
Installing pip...................done.
# Install flask
./venv/bin/pip install flask
# Activate flask
source flask/bin/activate

############################################# Airflow:
cd /apps/airflow/workspace
# Install venv
virtualenv -p `which python3` venv
# Activate venv
source venv/bin/activate

############################################# Zookeeper:
cd /usr/hdp/3.0.1.0-187/zookeeper
# Start zookeeper:
bin/zookeeper-server-start.sh config/zookeeper.properties

############################################# Kafka
# To start Kafka Broker, type the following command
cd /usr/hdp/3.0.1.0-187/kafka
bin/kafka-server-start.sh config/server.properties

# Создаем топик:
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic ilya.kruchinin

# Проверяем список топиков
bin/kafka-topics.sh --list --zookeeper localhost:2181

# Проверяем параметры кафки в ZooKeeper
/usr/hdp/3.0.1.0-187
# Стартуем консоль zookeeper:
zookeeper/bin/zkCli.sh -server localhost:2181
$  ls /brokers/ids  # Gives the list of active brokers
$  ls /brokers/topics #Gives the list of topics
$  get /brokers/ids/0 #Gives more detailed information of the broker id '0'

# Start produsser:
# Old server
# bin/kafka-console-producer.sh --broker-list 35.233.44.60:6667 --topic ilya.kruchinin

# New server:
bin/kafka-console-producer.sh --broker-list 35.204.145.90:6667 --topic ilya.kruchinin


# Запускаем консъюмер
# Читаем с самого начала, что есть в Kafka:
#bin/kafka-console-consumer.sh --zookeeper 35.233.44.60:2181 --topic ilya.kruchinin --from-beginning
bin/kafka-console-consumer.sh --zookeeper 35.204.145.90:2181 --topic ilya.kruchinin --from-beginning
#Читаем с offset:
#bin/kafka-console-consumer.sh --zookeeper 35.233.44.60:2181 --topic ilya.kruchinin
bin/kafka-console-consumer.sh --zookeeper 35.204.145.90:2181 --topic ilya.kruchinin

# Julia Evans