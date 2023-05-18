FROM adoptopenjdk/openjdk8:latest

WORKDIR /opt

ENV HADOOP_VERSION=3.3.4
ENV METASTORE_VERSION=3.1.3

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-3.1.3-bin
ENV HADOOP_OPTIONAL_TOOLS="hadoop-aws"

RUN curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/3.1.3/hive-standalone-metastore-3.1.3-bin.tar.gz | tar zxf -
RUN curl -L https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf -
RUN curl -L https://jdbc.postgresql.org/download/postgresql-42.2.16.jar --output postgresql-42.2.16.jar
RUN mv postgresql-42.2.16.jar ${HIVE_HOME}/lib/
RUN apt-get update && apt-get install -y netcat

COPY --chmod=0755 docker-scripts/hive/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN groupadd -r hive --gid=1000
RUN useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive
RUN chown hive:hive -R ${HIVE_HOME}
RUN chown hive:hive /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh
RUN mkdir -p /user/hive && chown hive:hive -R /user/hive


COPY ${PWD}/conf/metastore-site.xml /opt/apache-hive-metastore-3.1.3-bin/conf/metastore-site.xml

USER hive
EXPOSE 9083
EXPOSE 10000

ENTRYPOINT ["entrypoint.sh"]