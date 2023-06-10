#!/bin/bash

JAVAPATH=/usr/bin/java

if [ -d $JAVAPATH ]
then
	echo "Java is installed!"
else
	sudo apt-get -y  update
        sudo apt-get -y  install openjdk-11-jdk
fi

JAVAVERSION=$(java -version 2>&1 | awk -F '"' 'NR==1 {print $2}')
if [ ${JAVAVERSION:0:2} -lt 11 ]
then
   	sudo apt-get -y  update
    	sudo apt-get -y  install openjdk-11-jdk
else
	echo "JAVA version is 11 or higher, which is compatible!"
fi

TOMCATPATH=$HOME/tomcat9

if [ -d $TOMCATPATH ]
then
	echo "Directory exists!"
else
	mkdir $TOMCATPATH
fi

FILENAME=$TOMCATPATH'.tar.gz'

if [ -f "$FILENAME" ]
then
	echo "Tomcat file exists!"
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

WEBAPPSPATH=$TOMCATPATH/webapps

if [ -d $WEBAPPSPATH ]
then
	echo "/webapps is exists! Checking Jenkins!"
	JENKINNAME=$WEBAPPSPATH/jenkins.war
	if [ -f "$JENKINNAME" ]
        then
		echo "Jenkins file exists!"               
	else
		wget -O $JENKINNAME https://get.jenkins.io/war-stable/2.401.1/jenkins.war
      	fi
else
	echo "No directory exists!"
	
fi

$TOMCATPATH/bin/startup.sh
