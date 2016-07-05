##########################################################################
#  Author   M. Ritschel 
#           Trivadis GmbH Hamburg
#  Created: 28.06.2016 
#  Base-information 
#  ------------------------
# This Image based on https://github.com/MaksymBilenko/docker-oracle-12c
#  
##########################################################################
FROM sath89/oracle-12c-base

MAINTAINER Martin.Ritschel@Trivadis.com

LABEL Basic oracle 12c.R1 with java

# Environment
ENV DBCA_TOTAL_MEMORY=1024
ENV ORACLE_BASE=/u01/app/oracle
ENV ORACLE_HOME=$ORACLE_BASE/product/12.1.0/xe
ENV ORACLE_DATA=/u00/app/oracle/oradata 
ENV ORACLE_HOME_LISTNER=$ORACLE_HOME
ENV SERVICE_NAME=xe.oracle.docker
ENV PATH=$ORACLE_HOME/bin:$PATH
ENV NLS_DATE_FORMAT=DD.MM.YYYY\ HH24:MI:SS 
ENV ORACLE_SID=xe
ENV APEX_PASS=0Racle$
ENV PASS=oracle 
ENV INSTALL_HOME=/tmp/software 
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Installing the required software 
RUN apt-get update  && \ 
    apt-get upgrade -y && \
    apt-get install -y  software-properties-common && \
    apt-get -y install libpcre3 libssl-dev && \
    apt-get -y install libpcre3-dev && \
    apt-get -y install wget zip gcc ksh  && \
    apt-get -y install unzip && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean

# Copy the installation files
ADD software $INSTALL_HOME
RUN unzip $INSTALL_HOME/apex_5.0.3_1.zip -d $INSTALL_HOME
RUN unzip $INSTALL_HOME/apex_5.0.3_2.zip -d $INSTALL_HOME
RUN chmod -R 777 $INSTALL_HOME/*
RUN chown -R oracle:dba $INSTALL_HOME/* 

# Copy the installation scripts
ADD scripts /scripts
RUN chmod 777 /scripts/*
RUN /scripts/install.sh


# Ports 
EXPOSE 1521 
EXPOSE 8080

# Startup script to start the database in container
ENTRYPOINT ["/scripts/entrypoint.sh"]

# Define default command.
CMD ["bash"]
