#!/bin/bash
export HADOOP_HOME=${HADOOP_HOME:-/opt/hadoop}
export PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

# core-site.xml setup
cat <<EOF > ${HADOOP_CONF_DIR}/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://main:9000</value>
    </property>
</configuration>
EOF

# hdfs-site.xml setup with FAST HEARTBEATS
cat <<EOF > ${HADOOP_CONF_DIR}/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data/datanode</value>
    </property>
    <property>
        <name>dfs.heartbeat.interval</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.heartbeat.recheck-interval</name>
        <value>1000</value>
    </property>
</configuration>
EOF