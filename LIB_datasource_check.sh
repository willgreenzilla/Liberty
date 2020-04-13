#!/bin/bash

# LIB_datasource_check.sh v1.0
# Will Green / 04-13-2020

# Script to check the status of every datasource listed in the DATASOURCE_IDS variable.
# ./LIB_datasource.sh quick for a short output of each datasource status.
# ./LIB_datasource.sh full for long output w/error details.

DATASOURCE_IDS="db1 db2 db3 maindb1 maindb2 maindb3 auth1"
DATASOURCE_PATH="https://localhost:10447/ibm/api/validation/dataSource/"
USERNAME="admin"

pw()
{

echo "Enter the $USERNAME password: "
read -s PASSWORD

}

full()
{

echo ""

for DATASOURCE in $DATASOURCE_IDS
do
        curl -s -k -u $USERNAME:$PASSWORD ${DATASOURCE_PATH}${DATASOURCE}
        echo ""
done

}

quick()
{

echo ""

for DATASOURCE in $DATASOURCE_IDS
do
        curl -s -k -u $USERNAME:$PASSWORD ${DATASOURCE_PATH}${DATASOURCE} | grep -A 2 -B 1 '"id"'
        echo ""
done

}

case "$1" in

        quick|QUICK|q)
                pw
                quick
        ;;

        full|FULL|f)
                pw
                full
        ;;

        *)
                echo -e "\nUse quick for a datasource status summary or full for the entire datasource check output.\n"
                echo -e "./LIB_datasource_check.sh quick\n./LIB_datasource_check.sh full\n"
        ;;
esac