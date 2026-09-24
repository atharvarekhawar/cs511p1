####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

FROM eclipse-temurin:8-jdk-jammy

RUN apt update && \
    apt upgrade --yes && \
    apt install ssh openssh-server python3 --yes

COPY resources/configure-heartbeats.py /configure-heartbeats.py

# Setup common SSH key.
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/shared_rsa -C common && \
    cat ~/.ssh/shared_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Setup HDFS/Spark resources here

# Install dependencies
RUN apt update && \
    apt install -y curl wget tar && \
    rm -rf /var/lib/apt/lists/*

# Hadoop configuration
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

# Download and install Hadoop from Apache CDN
RUN curl -L --fail --retry 5 \
    https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    -o /tmp/hadoop.tar.gz && \
    tar -xzf /tmp/hadoop.tar.gz -C /opt && \
    mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm /tmp/hadoop.tar.gz

# Set JAVA_HOME for Hadoop
RUN echo "export JAVA_HOME=/opt/java/openjdk" \
    >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

# Create Hadoop data directories
RUN mkdir -p ${HADOOP_HOME}/data/namenode \
    ${HADOOP_HOME}/data/datanode

# Spark configuration
ENV SPARK_VERSION=3.4.1
ENV SPARK_HOME=/opt/spark
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV PATH="${SPARK_HOME}/bin:${PATH}"

# Download and install Spark. Try fast mirrors first, fall back to the slow
# Apache archive, and verify against the official SHA-512 either way.
ENV SPARK_SHA512=5a21295b4c3d1d3f8fc85375c711c7c23e3eeb3ec9ea91778f149d8d321e3905e2f44cf19c69a28df693cffd536f7316706c78932e7e148d224424150f18b2c5
RUN SPARK_TGZ=spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    for base in \
        https://mirror.lyrahosting.com/apache/spark \
        https://mirrors.huaweicloud.com/apache/spark \
        https://archive.apache.org/dist/spark; do \
        curl -L --fail --retry 3 --connect-timeout 10 "${base}/${SPARK_TGZ}" -o /tmp/spark.tgz && \
        echo "${SPARK_SHA512}  /tmp/spark.tgz" | sha512sum -c - && break; \
        rm -f /tmp/spark.tgz; \
    done && \
    test -f /tmp/spark.tgz && \
    tar -xzf /tmp/spark.tgz -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} && \
    rm /tmp/spark.tgz
