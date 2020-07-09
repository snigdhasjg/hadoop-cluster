FROM ubuntu:18.04

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget vim
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# install hadoop 2.7.7
RUN wget https://mirrors.estointernet.in/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz&& \
    tar -xzvf hadoop-2.7.7.tar.gz && \
    mv hadoop-2.7.7 /usr/local/hadoop && \
    rm hadoop-2.7.7.tar.gz
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH
ENV CLASSPATH=$HADOOP_HOME/lib/*:$CLASSPATH
RUN mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# install spark
RUN wget http://apachemirror.wuchna.com/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz && \
    tar -xvf spark-2.4.5-bin-hadoop2.7.tgz && \
    mv spark-2.4.5-bin-hadoop2.7 /usr/local/spark && \
    rm spark-2.4.5-bin-hadoop2.7.tgz
ENV SPARK_HOME=/usr/local/spark

# install sqoop 1.4.7
RUN wget http://apachemirror.wuchna.com/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    tar -xvf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    mv sqoop-1.4.7.bin__hadoop-2.6.0 /usr/lib/sqoop && \
    rm sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
ENV SQOOP_HOME=/usr/lib/sqoop
# install postgres 42.2.7
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.7.jre7.jar && \
    mv postgresql-42.2.7.jre7.jar $SQOOP_HOME/lib

# set path variables
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SQOOP_HOME/bin

# install hive
RUN wget https://archive.apache.org/dist/hive/hive-2.3.6/apache-hive-2.3.6-bin.tar.gz && tar -xvf apache-hive-2.3.6-bin.tar.gz
RUN rm apache-hive-2.3.6-bin.tar.gz
RUN mv apache-hive-2.3.6-bin /usr/local/hive && \
    cp /usr/local/hive/conf/hive-env.sh.template /usr/local/hive/conf/hive-env.sh
ENV HIVE_HOME=/usr/local/hive
ENV PATH=$HIVE_HOME/bin:$PATH:.
ENV CLASSPATH=$HIVE_HOME/lib/*:$CLASSPATH:.

# install mysql for hive
RUN apt-get install -y mysql-server libmysql-java
RUN ln -s /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib
RUN usermod -d /var/lib/mysql/ mysql
RUN service mysql start && \
    mysql -e "CREATE USER 'hiveuser'@'%' IDENTIFIED BY 'hivepassword';" && \
    mysql -e "GRANT all on hivedb.* to 'hiveuser'@localhost identified by 'hivepassword';" && \
    mysql -e "flush privileges;" && \
    service mysql stop

# install python and other deps
RUN apt install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa && apt update && apt install -y python && apt install -y python-pip
RUN apt-get install -y libgfortran3
RUN pip install numpy

COPY cluster/config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf && \
    mv /tmp/hive-site.xml /usr/local/hive/conf/hive-site.xml

RUN chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x /tmp/start-services.sh

ENV PATH=$HIVE_HOME/bin:$PATH
# format namenode
RUN hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]


