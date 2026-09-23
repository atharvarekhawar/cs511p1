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