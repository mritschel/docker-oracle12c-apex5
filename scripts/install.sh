#!/bin/bash
##########################################################################
#  Author   M. Ritschel 
#           Trivadis GmbH Hamburg
#  Created: 28.09.2016 
#  Base-information 
#  ------------------------
# Installation-Script for the Trivadis docker images
#  
##########################################################################
set -e

mkdir -p /entrypoint-initdb.d
# Read Hostname
HOSTNAME=$(cat /etc/hostname)

# Prevent owner issues on mounted folders
chown -R oracle:dba /u01/app/oracle
rm -f /u01/app/oracle/product
ln -s /u01/app/oracle-product /u01/app/oracle/product

#Run Oracle root scripts
/u01/app/oraInventory/orainstRoot.sh > /dev/null 2>&1
echo | /u01/app/oracle/product/12.1.0/xe/root.sh > /dev/null 2>&1 || true

echo "Checking tnsnames.ora"
if [ -f "${ORACLE_HOME}/network/admin/tnsnames.ora" ] 
then 
	echo "tnsnames.ora found." 
	rm -f ${ORACLE_HOME}/network/admin/tnsnames.ora
fi 
echo "Creating tnsnames.ora"  
printf "${ORACLE_SID} = 
   (DESCRIPTION = 
      (ADDRESS = (PROTOCOL = TCP)
      (HOST = $HOSTNAME) 
      (PORT = 1521)) 
      (CONNECT_DATA = 
         (SERVICE_NAME = ${SERVICE_NAME})
      )
   )\n" > ${ORACLE_HOME}/network/admin/tnsnames.ora 
chown -R oracle:dba ${ORACLE_HOME}/network/admin/tnsnames.ora

# Start database installation
echo "Initializing database."
mv /u01/app/oracle-product/12.1.0/xe/dbs /u01/app/oracle/dbs
ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.1.0/xe/dbs

#create DB for SID: xe
su oracle -c "$ORACLE_HOME/bin/dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname xe.oracle.docker -sid xe -responseFile NO_VALUE -characterSet AL32UTF8 -totalMemory $DBCA_TOTAL_MEMORY -emConfiguration LOCAL -pdbAdminPassword oracle -sysPassword oracle -systemPassword oracle"

#move the apex instalations files to ${ORACLE_HOME}
echo "Move the apex 5.0.3 instalations files to oracle_home"
mv ${ORACLE_HOME}/apex ${ORACLE_HOME}/apex_old
mv ${INSTALL_HOME}/apex ${ORACLE_HOME}
chown -R oracle:dba ${ORACLE_HOME}/apex
chmod -R 775 ${ORACLE_HOME}/apex

#config Apex console
echo "Configuring Apex console"
cd $ORACLE_HOME/apex
su oracle -c 'echo -e "${PASS}\n8060" | $ORACLE_HOME/bin/sqlplus -S / as sysdba @apxconf > /dev/null'
su oracle -c 'echo -e "${ORACLE_HOME}\n\n" | $ORACLE_HOME/bin/sqlplus -S / as sysdba @apex_epg_config_core.sql > /dev/null'
su oracle -c 'echo -e "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | $ORACLE_HOME/bin/sqlplus -S / as sysdba > /dev/null'
su oracle -c 'echo -e "${ORACLE_HOME}\n\n" | $ORACLE_HOME/bin/sqlplus -S / as sysdba @apxxepwd ${APEX_PASS} > /dev/null'

echo "Set NAMES.DEFAULT_DOMAIN for the sqlnet..."
# sqlnet modify 
STRSEARCH="NAMES.DEFAULT_DOMAIN"
STRREPLACE="#NAMES.DEFAULT_DOMAIN"
find "${ORACLE_BASE}/network/admin" -type f -name '*.ora' -print | while read i
do
   cp "$i" "$i.tmp"
   if [ -f "$i.tmp" ]; then
      #echo "s/$STRSEARCH/$STRREPLACE/g"
      sed "s/$STRSEARCH/$STRREPLACE/g" "$i" > "$i.new"
      if [ -f "$i.new" ]; then
          mv "$i.new" "$i"
      else
         echo "$i.new doesn't exist"
      fi
   else
      echo "$i.tmp wasn't created"
   fi
done

# clearing
echo "Clearing"
rm -f /scripts/install.sh
rm -fr $INSTALL_HOME/* 
