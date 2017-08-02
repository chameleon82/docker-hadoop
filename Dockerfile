FROM chameleon82/java

RUN curl -s http://www-eu.apache.org/dist/hadoop/common/hadoop-2.8.1/hadoop-2.8.1.tar.gz | tar -xz -C /opt && \
    ln -s /opt/hadoop-2.8.1 /opt/hadoop

ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_PREFIX /opt/hadoop

RUN yum -y install which openssh openssh-server openssh-clients openssl-libs pdsh && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    ssh-keygen -A && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java\nexport HADOOP_PREFIX=/opt/hadoop\nexport HADOOP_HOME=/opt/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    $HADOOP_PREFIX/bin/hdfs namenode -format 

RUN echo $'<configuration>\n\
    <property>\n\
        <name>fs.defaultFS</name>\n\
        <value>hdfs://localhost:9000</value>\n\
    </property>\n\
</configuration>\n'\
    > $HADOOP_PREFIX/hadoop/core-site.xml  && \
   echo $'<configuration>\n\
    <property>\n\
        <name>dfs.replication</name>\n\
        <value>1</value>\n\
    </property>\n\
</configuration>\n'\
    > $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml && \
    echo $'<configuration>\n\
     <property>\n\
        <name>mapreduce.framework.name</name>\n\
        <value>yarn</value>\n\
     </property>\n\
</configuration>\n'\
    > $HADOOP_PREFIX/etc/hadoop/mapred-site.xml && \
    echo $'<configuration>\n\
    <property>\n\
        <name>yarn.nodemanager.aux-services</name>\n\
        <value>mapreduce_shuffle</value>\n\
    </property>\n\
</configuration>\n'\
    > $HADOOP_PREFIX/etc/hadoop/yarn-site.xml && \
    echo $'Host *\n\
  UserKnownHostsFile /dev/null\n\
  StrictHostKeyChecking no\n\
  LogLevel quiet\n'\
  > /root/.ssh/config && \
  echo $'#!/bin/bash\n\
/usr/sbin/sshd\n\
sbin/start-dfs.sh\n\
sbin/start-yarn.sh\n\
tail -f /dev/null\n'\
 > /entrypoint.sh && \
chmod +x /entrypoint.sh

EXPOSE 50070 8088

WORKDIR /opt/hadoop

ENTRYPOINT /entrypoint.sh
