#!/bin/bash
sh cluster/stop.sh

docker network create --driver=bridge hadoop

N=${1:-4}

# start hadoop master container
echo "start hadoop-master container..."
docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
                -p 7077:7077 \
                -p 16010:16010 \
                -p 18080:18080 \
                -p 4040:4040 \
                --name hadoop-master \
                --hostname hadoop-master \
                spark-hadoop:latest &> /dev/null
sleep 5

# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	echo "start hadoop-slave$i container..."
	port=$(( 8040 + $i ))
	port2=$(( 50075 + $i ))
	docker run -itd \
			-p $port:8042 -p $port2:50075\
	                --net=hadoop \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                spark-hadoop:latest &> /dev/null
	i=$(( $i + 1 ))
	sleep 5
done 

docker exec -it hadoop-master /tmp/start-services.sh
