FROM ubuntu:14.04
MAINTAINER forsrc <forsrc@gmail.com>

# Add R list
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/' | sudo tee -a /etc/apt/sources.list.d/r.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# packages
RUN apt-get update && apt-get install -yq --no-install-recommends --force-yes \
    wget \
    git \
    openjdk-7-jdk \
    maven \
    libjansi-java \
    libsvn1 \
    libcurl3 \
    libsasl2-modules && \
    rm -rf /var/lib/apt/lists/*

# Overall ENV vars
ENV SPARK_VERSION       1.6.1
ENV MESOS_BUILD_VERSION 0.28.0-2.0.16
ENV LIVY_BUILD_VERSION  0.4.0-incubating

# Set install path for Livy
ENV LIVY_APP_PATH   /apps/livy-$LIVY_BUILD_VERSION-bin

# Set build path for Livy
ENV LIVY_BUILD_PATH /apps/build/livy

# Set Hadoop config directory
ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Set Spark home directory
ENV SPARK_HOME /usr/local/spark

# Set native Mesos library path
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/local/lib/libmesos.so

# Mesos install
RUN wget http://repos.mesosphere.com/ubuntu/pool/main/m/mesos/mesos_$MESOS_BUILD_VERSION.ubuntu1404_amd64.deb && \
    dpkg -i mesos_$MESOS_BUILD_VERSION.ubuntu1404_amd64.deb && \
    rm mesos_$MESOS_BUILD_VERSION.ubuntu1404_amd64.deb

# Spark ENV vars
ENV SPARK_VERSION_STRING spark-$SPARK_VERSION-bin-hadoop2.6
ENV SPARK_DOWNLOAD_URL http://d3kbcqa49mib13.cloudfront.net/$SPARK_VERSION_STRING.tgz

# Download and unzip Spark
RUN wget $SPARK_DOWNLOAD_URL && \
    mkdir -p $SPARK_HOME && \
    tar xvf $SPARK_VERSION_STRING.tgz -C /tmp && \
    cp -rf /tmp/$SPARK_VERSION_STRING/* $SPARK_HOME && \
    rm -rf -- /tmp/$SPARK_VERSION_STRING && \
    rm spark-$SPARK_VERSION-bin-hadoop2.6.tgz

# Clone Livy repository
RUN mkdir -p /apps/build && \
    cd /apps/build && \
	  wget http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/incubator/livy/$LIVY_BUILD_VERSION/livy-$LIVY_BUILD_VERSION-bin.zip && \
    unzip livy-$LIVY_BUILD_VERSION-bin.zip -d /apps && \
    rm -rf $LIVY_BUILD_PATH && \
	  mkdir -p $LIVY_APP_PATH/upload

# Add custom files, set permissions
ADD entrypoint.sh .

RUN mkdir $LIVY_APP_PATH/logs
RUN chmod u+x entrypoint.sh
RUN chmod u+w /apps

# Expose port
EXPOSE 8998

ENTRYPOINT ["/entrypoint.sh"]
