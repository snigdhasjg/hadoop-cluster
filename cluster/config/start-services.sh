#!/bin/bash

echo "Starting mysql server"
service mysql start

echo "starting hadoop"
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

echo "cleaning spark log"
hadoop fs -mkdir /spark-logs

echo "start spark history server"
sh /usr/local/spark/sbin/start-history-server.sh


echo "run hive init"
schematool -initSchema -dbType mysql
mkdir ~/hiveserver2log
cd ~/hiveserver2log
nohup hiveserver2 &
nohup hive --service hiveserver2 &
nohup hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=INFO,console &

mkdir ~/hivemetastorelog
cd ~/hivemetastorelog
nohup hive --service metastore &
