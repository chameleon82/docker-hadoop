FROM java:8

RUN curl -s http://www-us.apache.org/dist/hadoop/common/hadoop-2.8.1/hadoop-2.8.1.tar.gz | tar -xz -C /opt/

RUN ln -s /opt/hadoop-2.8.1 /usr/local/hadoop

RUN apt-get update && \
    apt-get -y install ssh pdsh

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

RUN echo 'Host *\n\
  UserKnownHostsFile /dev/null\n\
  StrictHostKeyChecking no\n\
  LogLevel quiet\n'\
  > /root/.ssh/config

ENV HADOOP_HOME /usr/local/hadoop

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64:' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

ADD dockerfiles /

WORKDIR /usr/local/hadoop

RUN bin/hdfs namenode -format

# ENV PATH $PATH:$HADOOP_HOME/bin

EXPOSE  8088 8042

# Daemon                   Default Port  Configuration Parameter
# -----------------------  ------------ ----------------------------------
# ResourceManager          8088
# NodeManager              8042

EXPOSE 50070 50075 50090 50105 50030 50060

# Daemon                   Default Port  Configuration Parameter
# -----------------------  ------------ ----------------------------------
# Namenode                 50070        dfs.http.address
# Datanodes                50075        dfs.datanode.http.address
# Secondarynamenode        50090        dfs.secondary.http.address
# Backup/Checkpoint node?  50105        dfs.backup.http.address
# Jobracker                50030        mapred.job.tracker.http.address
# Tasktrackers             50060        mapred.task.tracker.http.address


CMD bash /entrypoint.sh

# RUN sudo addgroup hadoop && \
#     sudo adduser --ingroup hadoop hduser && \
# sudo usermod -aG sudo hduser

# IPC ports
# Daemon      Default Port        Configuration Parameter
# ------------------------------------------------------------
# Namenode    9000                fs.default.name
# Datanode    50010               dfs.datanode.address
# Datanode    50020               dfs.datanode.ipc.address
# Backupnode  50100               dfs.backup.address
