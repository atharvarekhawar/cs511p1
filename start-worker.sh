#!/bin/bash

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

/etc/init.d/ssh start
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shared_rsa

# Apply the supplied timing before the student service-start commands below.
# No Hadoop installation is expected in the unfinished Part 0 starter.
if command -v hdfs >/dev/null 2>&1; then
    python3 /configure-heartbeats.py || exit 1
fi

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Start HDFS/Spark worker here

export HADOOP_HOME=${HADOOP_HOME:-/opt/hadoop}
export PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

# Start DataNode daemon on worker nodes
hdfs --daemon start datanode

# Wait for the Spark master, then start a worker
export SPARK_HOME=${SPARK_HOME:-/opt/spark}
for i in {1..60}; do
    (echo > /dev/tcp/main/7077) 2>/dev/null && break
    sleep 1
done
${SPARK_HOME}/sbin/start-worker.sh spark://main:7077

bash
