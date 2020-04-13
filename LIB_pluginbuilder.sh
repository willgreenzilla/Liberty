#!/bin/bash

# LIB_pluginbuilder.sh v1.0
# Will Green / 03-09-2020

# Script to generate fresh plugin-cfg.xml files for listed servers, merge them together info a single
# plugin-cfg.xml, and to finally push the plugin to the listed webserver(s).

LIBERTYSERVERS="server1 server2 server3 server4 server5"
APPSERVERS="appserver-host-1 appserver-host-2"
NOTME="appserver-host-2"
WEBSERVERS="webserver1 webserver2"
BINPATH="/opt/IBM/wlp/bin/"
PLUGINPATH="/opt/IBM/wlp/plugins/"
PLUGINFILES=$(ls $PLUGINPATH)
PLUGINHOME="/opt/IBM/wasadmin/Plugins/config/webserver/"
COUNTER=1

build()
{

        echo -e "\nBuilding merged plugin-cfg.xml..."

        rm ${PLUGINPATH}*

        for LIBERTYSERVER in $LIBERTYSERVERS
        do
                /bin/bash ${BINPATH}pluginUtility generate --server=$LIBERTYSERVER --targetpath=${PLUGINPATH}plugin-cfg-${LIBERTYSERVER}.xml
        done

        for NOTI in $NOTME
        do
                for LIBERTYSERVER in $LIBERTYSERVERS
                do
                        ssh -q wasadmin@$NOTI /bin/bash ${BINPATH}pluginUtility generate --server=$LIBERTYSERVER --targetpath=${PLUGINPATH}plugin-cfg-${LIBERTYSERVER}-${COUNTER}.xml
                        scp -q wasadmin@${NOTI}:${PLUGINPATH}plugin-cfg-${LIBERTYSERVER}-${COUNTER}.xml ${PLUGINPATH}/.
                done
                ((COUNTER++))
        done

}

adjust()
{

        # Add port 443 to VirtualHost list
        sed -i 's/      <VirtualHost Name="\*:8443"\/>/      <VirtualHost Name="\*:8443"\/>\n      <VirtualHost Name="\*:443"\/>/g' ${PLUGINPATH}*

}

merge()
{

        /bin/bash ${BINPATH}pluginUtility merge --sourcePath=${PLUGINPATH} --targetPath=/opt/IBM/wlp/plugins/plugin-cfg.xml
        # Remove ugly multi newline block near top of file
        sed -i -r ':a; /^\s*$/ {N;ba}; s/( *\n *){2,}/\n/' ${PLUGINPATH}plugin-cfg.xml

        echo -e "\nMerged plugin-cfg.xml has been assembled: ${PLUGINPATH}plugin-cfg.xml\n"
}

push()
{

        for WEBSERVER in $WEBSERVERS
        do
                echo -e "\nBacking up old plugin-cfg.xml file & pushing new merged plugin-cfg.xml to $WEBSERVER"

                ssh -q wasadmin@$WEBSERVER cp ${PLUGINHOME}plugin-cfg.xml ${PLUGINHOME}plugin-cfg.xml.old
                scp -q ${PLUGINPATH}plugin-cfg.xml wasadmin@${WEBSERVER}:${PLUGINHOME}plugin-cfg.xml

                echo -e "\nReplacement complete!\n\nBouncing IHS...\n"

                ssh -q wasadmin@$WEBSERVER /bin/bash /opt/IBM/wasadmin/HTTPServer/bin/apachectl stop;sleep 3s;/bin/bash /opt/IBM/wasadmin/HTTPServer/bin/adminctl stop
                ssh -q wasadmin@$WEBSERVER /bin/bash /opt/IBM/wasadmin/HTTPServer/bin/adminctl start;sleep 3s;/bin/bash /opt/IBM/wasadmin/HTTPServer/bin/apachectl start

                echo -e "\nIHS has been bounced on ${WEBSERVER} and new plugin-cfg.xml loaded!\n"

        done

        echo -e "Merged plugin-cfg.xml push has been completed!\n"

}

case "$1" in

        build|BUILD)
                build
                adjust
                merge
        ;;

        push|PUSH)
                push
        ;;
        *)
                echo -e "\nUse build to generate merged plugin-cfg.xml or push to push plugin-cfg.xml out to the webservers.\n"
                echo -e "./LIB_pluginbuilder.sh build\n./LIB_pluginbuilder.sh push\n"
        ;;

esac

exit
