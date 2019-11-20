FROM ubuntu:latest

RUN apt-get update && apt-get install -y openssh-server software-properties-common ssh vim git
RUN apt-get install openjdk-8-jdk openjdk-8-jre -y

RUN mkdir /var/run/sshd

RUN ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys

RUN mkdir -p /data/hdfs /data-1/hdfs /hadoop /logs/hadoop /logs/yarn
RUN wget -c -O hadoop.tar.gz http://www-eu.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz

RUN tar -xvf hadoop.tar.gz --directory=/hadoop --strip 1

# Setting up all the environment variables.
RUN echo "export HADOOP_HOME=/hadoop" >> /root/.bashrc
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /root/.bashrc
RUN echo "export JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre" >> /root/.bashrc
RUN echo "export HDFS_NAMENODE_USER=root" >> /root/.bashrc
RUN echo "export HDFS_DATANODE_USER=root" >> /root/.bashrc
RUN echo "export HDFS_SECONDARYNAMENODE_USER=root" >> /root/.bashrc
RUN echo "export YARN_RESOURCEMANAGER_USER=root" >> /root/.bashrc
RUN echo "export YARN_NODEMANAGER_USER=root" >> /root/.bashrc
RUN echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/hadoop/bin:/hadoop/sbin" >> /root/.bashrc

COPY configurations/* /hadoop/etc/hadoop/
COPY hadoop_workers.dat /hadoop/etc/hadoop/workers

# ResourceManager Default HTTP Web UI Port - 8088
# MapReduce JobHistoryServer Default HTTP Web UI Port - 19888
# HDFS NameNode Web UI Port - 50070

EXPOSE 8088 19888 50070

CMD ["/usr/sbin/sshd", "-D"]