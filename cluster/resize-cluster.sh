#!/bin/bash

# N is the node number of hadoop cluster
N=$1

if [[ $# = 0 ]]
then
	echo "Please specify the node number of hadoop cluster!"
	exit 1
fi

# change slaves file
i=1
rm ./cluster/config/slaves
while [[ ${i} -lt ${N} ]]
do
	echo "hadoop-slave$i" >> ./cluster/config/slaves
	i=$(( $i + 1 ))
done

sed -i '' "s/N=\${1:-4}/N=\${1:-$N}/g" ./cluster/start.sh

echo ""

echo -e "\nbuild docker hadoop image\n"

sh build-image.sh

echo ""
