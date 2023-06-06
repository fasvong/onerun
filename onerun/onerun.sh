#!/bin/sh

sudo apt-get update
sudo apt-get install openjdk-11-jdk

export TOMCATPATH=$HOME/tomcat9

if [ -d $TOMCATPATH  ]
then
	echo "Directory exists!"
else
	mkdir $TOMCATPATH
fi

FILENAME=$TOMCATPATH'.tar.gz'

wget -O $FILENAME https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz

tar -xf $FILENAME -C $TOMCATPATH --strip-components=1

TOMCATUSERFILE=$TOMCATPATH/conf/tomcat-users.xml
CONTEXTFILE=$TOMCATPATH/webapps/manager/META-INF/context.xml


cp $HOME/onerun/tomcat-users.xml $CONFIGURATIONFILE
chown --reference=context.xml tomcat-users.xml

cp $HOME/onerun/context.xml $CONTEXTFILE
chown --reference=context.xml $CONFIGURATIONFILE 


$TOMCATPATH/bin/startup.sh
