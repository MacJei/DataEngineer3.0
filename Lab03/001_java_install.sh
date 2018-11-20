Java8
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

Далее добавим путь к Java в окружение:

$ sudo nano /etc/environment
Там нужно вставить следующую строчку JAVA_HOME="/usr/lib/jvm/java-8-oracle" и сохранить файл.

source /etc/environment
echo $JAVA_HOME

Результат должен быть таким:
/usr/lib/jvm/java-8-oracle