#!/bin/sh

if which java > /dev/null 2>&1; 
then
    sudo apt-get update
	sudo apt-get install openjdk-11-jdk
else
    echo "Java not installed"
fi

export TOMCATPATH=$HOME/tomcat9

if [ -d $TOMCATPATH  ]
then
	echo "Directory exists!"
else
	mkdir $TOMCATPATH
fi

FILENAME=$TOMCATPATH'.tar.gz'

if [ -f $FILENAME]
then
	echo "File exists!"
else
	wget -O $FILENAME https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
	tar -xf $FILENAME -C $TOMCATPATH --strip-components=1
fi

TOMCATUSERFILE=$TOMCATPATH/conf/tomcat-users.xml
CONTEXTFILE=$TOMCATPATH/webapps/manager/META-INF/context.xml
CHMODCP=$TOMCATPATH/conf/context.xml

cp $HOME/git/onerun/onerun/tomcat-users.xml $TOMCATUSERFILE
chown --reference=$CHMODCP $TOMCATUSERFILE

cp $HOME/git/onerun/onerun/context.xml $CONTEXTFILE
chown --reference=$CHMODCP $CONTEXTFILE 

WEBAPPSPATH=$TOMCATPATH/webapps/

if [ -d $TOMCATPATH/webapps/]
then
	JENKINNAME=$WEBAPPSPATH/jenkins.war
	wget -O $JENKINNAME https://get.jenkins.io/war-stable/2.401.1/jenkins.war
else
	echo "No directory exists!"
fi

$TOMCATPATH/bin/startup.sh
