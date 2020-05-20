# Create a Docker network for communication between Docker containers for Apache Hadoop.
docker network ls | grep 'hadoop-net' &> /dev/null
if [[ $? == 0 ]]; then
	echo 'Docker network already exists. Skipping network creation.'
else
	echo 'Creating new Docker network: hadoop-net'
	docker network create hadoop-net
fi

# Running container image of hadoop-in-docker for Hadoop-Master.
docker container ls | grep 'hadoop-master' &> /dev/null
if [[ $? == 0 ]]; then
	echo 'An instance of hadoop-in-docker as hadoop-master is already running. Stopping running instance.'
    docker stop hadoop-master
    echo 'Removing namenode instance.'
    docker rm hadoop-master
fi
    docker run -itd --network hadoop-net -p 9870:9870 -p 8088:8088 -p 19888:19888 -p 8031:8031 --name hadoop-master -h hadoop-master uselesscoder/hadoop-in-docker:latest

# Running container image of hadoop-in-docker for Hadoop-Slave-1.
docker container ls | grep 'hadoop-slave-1' &> /dev/null
if [[ $? == 0 ]]; then
	echo 'An instance of hadoop-in-docker as hadoop-slave-1 is already running. Stopping running instance.'
    docker stop hadoop-slave-1
    echo 'Removing hadoop-slave-1 instance.'
    docker rm hadoop-slave-1
fi
docker run -itd --network hadoop-net --name hadoop-slave-1 -h hadoop-slave-1 uselesscoder/hadoop-in-docker:latest


# Running container image of hadoop-in-docker for Hadoop-Slave-2.
docker container ls | grep 'hadoop-slave-2' &> /dev/null
if [[ $? == 0 ]]; then
	echo 'An instance of hadoop-in-docker as hadoop-slave-2 is already running. Stopping running instance.'
    docker stop hadoop-slave-2
    echo 'Removing hadoop-slave-2 instance.'
    docker rm hadoop-slave-2
fi
docker run -itd --network hadoop-net --name hadoop-slave-2 -h hadoop-slave-2 uselesscoder/hadoop-in-docker:latest

# Formatting NameNode for first time run.
docker exec hadoop-master bash -c "/hadoop/bin/hdfs namenode -format hadoop_cluster"

# Starting HDFS Service.
docker exec hadoop-master bash -c "/hadoop/sbin/start-dfs.sh"

# Starting YARN Service.
docker exec hadoop-master bash -c "/hadoop/sbin/start-yarn.sh"
