#!/bin/bash
set -e

source $SCRIPTS_HOME/colorecho

# Add oracle to path
export PATH=$ORACLE_HOME/bin:$PATH
if grep -q "PATH" ~/.bashrc
then
    echo "Found PATH definition in ~/.bashrc"
else
	echo "Extending PATH in in ~/.bashrc"
	printf "\nPATH=${PATH}\n" >> ~/.bashrc
fi

echo_yellow  "Starting listener and database"
echo_yellow "---------------------------------------------------------------------------"
echo_yellow "Database and Web management console initialized. Please visit"
echo_yellow "   - http://localhost:5500/em"
echo_yellow "   - http://localhost:8080/apex"
echo_yellow "\n"
echo_yellow "---------------------------------------------------------------------------"
$SCRIPTS_HOME/startup.sh database
