# Oracle database 12c release 1 with Apex 5.0.3 
--------------------------------------------------------

## Content

This Dockerfile is based on my work for [https://hub.docker.com/r/mritschel/oraclebase]. The version is based on the image with Oracle Enterprise Linux 7.1 and Oracle Database 12c R1.
The resulting image contains the following:

* Oracle Enterprise Linux 7.1
* Oracle Database 12.1.0.2 Enterprise Edition 
	* Apex 5.0.3 
	* Java(TM) SE Runtime Environment (build 1.8.0_91-b14)
	* Perl 5.14.1
	
Pull the latest trusted build from [here](https://hub.docker.com/r/mritschel/docker-oracle12c-apex5).


## Installation

### Using Default Settings (recommended)

Complete the following steps to create a new container:

1. Pull the image

		docker pull mritschel/docker-oracle12c-apex5

2. Create the container

		docker run -d -p 8080:8080 -p 1521:1521 -p 9090:9090 -h xe --name oracle-apex mritschel/oracle12c-apex
		
3. wait around **15 minutes** until the Oracle Database and APEX is created. Check logs with ```docker logs oracle-apex```. The container is ready to use when the last line in the log is ```Oracle started Successfully ! ;)```. The container stops if an error occurs. Check the logs to determine how to proceed.


### Options

#### Environment Variables

You may set the environment variables in the docker run statement to configure the container setup process. The following table lists all environment variables with its default values:

Environment variable | Default value | Comments
-------------------- | ------------- | --------
DBCA_TOTAL_MEMORY | ```1024``` | Keep in mind that DBCA fails if you set this value too low
ORACLE_BASE | ```/u01/app/oracle``` | Oracle Base directory
ORACLE_HOME | ```$ORACLE_BASE/product/12.1.0/xe``` | Oracle Home directory
ORACLE_DATA | ```/u00/app/oracle/oradata``` | Oracle Data directory
ORACLE_HOME_LISTNER | ```$ORACLE_HOME``` | Oracle Home directory
SERVICE_NAME | ```xe.local.com``` | Oracle service name
PATH | ```$ORACLE_HOME/bin:$PATH``` | Path
NLS_DATE_FORMAT | ```DD.MM.YYYY\ HH24:MI:SS``` | Oracle NLS date format
ORACLE_SID | ```xe``` | The Oracle SID
APEX_PASS | ```0Racle$``` | Set a different initial APEX ADMIN password (the one which must be changed on first login)
PASS | ```oracle``` | Password for SYS and SYSTEM
INSTALL_HOME | ```/tmp/software``` | Install directory

Here's an example run call amending the SYS/SYSTEM password and DBCA memory settings:

```
docker run -e PASS=manager -e DBCA_TOTAL_MEMORY=1536 -d -p 8080:8080 -p 1521:1521 -p 9090:9090 -h xe --name oracle-apex mritschel/oracle12c-apex
```

#### Volumes

The image defines a volume for ```/apex```. You may map this volume for the apex_HOME. Here's an example using a named volume ```/apex```:

```
docker run -v /apex:/apex -d -p 8080:8080 -p 1521:1521 -p 9090:9090 -h xe --name oracle-apex mritschel/oracle12c-apex
```

## Access

### Enterprise Manager Database Express 12c

[http://localhost:8080/em/](http://localhost:8080/em/)


### Access APEX

[http://localhost:8080/apex/](http://localhost:8080/apex/)

Property | Value 
-------- | -----
Workspace | INTERNAL
User | ADMIN
Password | 0Racle$

### Database Connections

To access the database e.g. from SQL Developer you configure the following properties:

Property | Value 
-------- | -----
Hostname | localhost
Port | 1521
SID | xe
Service | xe.local.com

The configured user with their credentials are:

User | Password 
-------- | -----
system | oracle
sys | oracle
 
Linux
User | Password 
-------- | -----
root | geheim
oracle | geheim


## Backup

Complete the following steps to backup the data volume:

1. Stop the container with 

		docker stop oracle-apex
		
2. Backup the data volume to a compressed file ```xe.tar.gz``` in the current directory with a little help from the ubuntu image

		docker run --rm --volumes-from oracle-apex -v $(pwd):/backup ubuntu tar czvf /backup/oracle-apex.tar.gz /u01/app/oracle
		
3. Restart the container

		docker start oracle-apex


## Issues

Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/): 

* [Existing issues](https://github.com/mritschel/docker-oracle12c-apex/issues)
* [submit new issue](https://github.com/mritschel/docker-oracle12c-apex/issues/new)

## License

docker-oracle12c-apex is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>. 

See [Oracle Database Licensing Information User Manual](http://docs.oracle.com/database/121/DBLIC/editions.htm#DBLIC109) and [Oracle Database 12c Standard Edition 2](https://www.oracle.com/database/standard-edition-two/index.html) for further information.
