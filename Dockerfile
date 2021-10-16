#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ARG SPARK_IMAGE=gcr.io/spark-operator/spark-py:v3.1.1-hadoop3
FROM ${SPARK_IMAGE}

# Switch to user root so we can add additional jars and configuration files.
USER root

ADD https://raw.githubusercontent.com/yinanli617/ctr-prediction/master/pyspark-job.py /pipelines/
ADD ./requirements.txt /pip-requirements/
RUN pip3 install -r /pip-requirements/requirements.txt

# Setup dependencies for Google Cloud Storage access.
RUN rm $SPARK_HOME/jars/guava-14.0.1.jar

ADD https://repo1.maven.org/maven2/com/google/guava/failureaccess/1.0.1/failureaccess-1.0.1.jar $SPARK_HOME/jars
RUN chmod 644 $SPARK_HOME/jars/failureaccess-1.0.1.jar
ADD https://repo1.maven.org/maven2/com/google/guava/guava/31.0.1-jre/guava-31.0.1-jre.jar $SPARK_HOME/jars
RUN chmod 644 $SPARK_HOME/jars/guava-31.0.1-jre.jar
# Add the connector jar needed to access Google Cloud Storage using the Hadoop FileSystem API.
ADD https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-latest.jar $SPARK_HOME/jars
RUN chmod 644 $SPARK_HOME/jars/gcs-connector-hadoop3-latest.jar
ADD https://storage.googleapis.com/spark-lib/bigquery/spark-bigquery-latest_2.12.jar $SPARK_HOME/jars
RUN chmod 644 $SPARK_HOME/jars/spark-bigquery-latest_2.12.jar


RUN mkdir -p /opt/hadoop/conf
RUN mkdir -p $SPARK_HOME/conf
COPY conf/core-site.xml /opt/hadoop/conf
COPY conf/spark-env.sh $SPARK_HOME/conf

ENTRYPOINT ["/opt/entrypoint.sh"]
