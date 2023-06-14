#!/bin/sh

#------------JAVA
#JAVAPATH=/usr/bin/java

#if [ -d $JAVAPATH ]
#then
#   echo "Java is installed!"
#else
#   sudo apt-get -y  update
#        sudo apt-get -y  install openjdk-11-jdk
#fi

#JAVAVERSION=$(java -version 2>&1 | awk -F '"' 'NR==1 {print $2}')
#if [ ${JAVAVERSION:0:2} -lt 11 ]
#then
#       sudo apt-get -y  update
#       sudo apt-get -y  install openjdk-11-jdk
#else
#   echo "JAVA version is 11 or higher, which is compatible!"
#fi
#-----------------

# Default values

# Help function
print_help() {
    echo "Usage: onerun.sh [OPTIONS]"
    echo "Options:"
    echo "  -h, --help                 Display this help message"
    echo "  -t, --tomcatversion        Required: Tomcat version"
    echo "  -j, --jenkinsversion       Required: Jenkins version"
}

# Parse arguments
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -h|--help)
            print_help
            exit 0
            ;;
        -t|--tomcatversion)
            tomcat_version="$2"
            shift
            ;;
        -j|--jenkinsversion)
            jenkins_version="$2"
            shift
            ;;
        *)
            echo "Unknown option: $key"
            echo "Please refer the help below."
            print_help
            exit 1
            ;;
    esac
    shift
done

# Check for required parameters
if [ -z "$tomcat_version" ] || [ -z "$jenkins_version" ]; 
then
    echo "Error: Missing required parameters"
    print_help
    exit 1
else
    # Find the PID of TOMCAT and kill
    PID=$(pgrep java)
    
    if [ -z "$PID" ]; 
    then
        echo "Tomcat process is not running."
    else
        echo "Process PID: $PID"
        # Kill the process
        kill "$PID"
        echo "Tomcat process has been killed."
    fi
    # Find the PID of TOMCAT and kill
    
    #TOMCAT
    TOMCATPATH=$HOME/tomcat9

    if [ -d $TOMCATPATH ]
    then
        echo "Directory exists!"
    else
        mkdir $TOMCATPATH
    fi
    
    TOMCATFILE=$TOMCATPATH'.tar.gz'
    
    if [ -f "$TOMCATFILE" ]
    then
		TOMCATFILESIZE=${stat -c%s $TOMCATFILE}
		if [ $TOMCATFILESIZE -le 0 ]
		then
			echo "Error: TOMCAT tar file size is 0"
			exit 1
		else
			echo "Tomcat file exists!"
		fi
    else
        wget -O $TOMCATFILE https://dlcdn.apache.org/tomcat/tomcat-9/v$tomcat_version/bin/apache-tomcat-$tomcat_version.tar.gz
		TOMCATFILESIZE=${stat -c%s $TOMCATFILE}
		if [ $TOMCATFILESIZE -le 0 ]
		then
			echo "Error: TOMCAT tar file size is 0"
			exit 1
		else
			tar -xf $TOMCATFILE -C $TOMCATPATH --strip-components=1
		fi
    fi
    
    TOMCATUSERFILE=$TOMCATPATH/conf/tomcat-users.xml
    CONTEXTFILE=$TOMCATPATH/webapps/manager/META-INF/context.xml
    CHMODCP=$TOMCATPATH/conf/context.xml
    
	if [ -f "$HOME/onerun/onerun/tomcat-users.xml" ]
	then
		cp $HOME/onerun/onerun/tomcat-users.xml $TOMCATUSERFILE
		chown --reference=$CHMODCP $TOMCATUSERFILE
	else
		echo "File is not exists!"
		exit 1
	fi
    
    if [ -f "$HOME/onerun/onerun/context.xml" ]
	then
		cp $HOME/onerun/onerun/context.xml $CONTEXTFILE
		chown --reference=$CHMODCP $CONTEXTFILE
	else
		echo "File is not exists!"
		exit 1
	fi
     
    #TOMCAT
    
    #JENKINS
    WEBAPPSPATH=$TOMCATPATH/webapps
    
    #Create Archive folder in webapps
    mkdir $WEBAPPSPATH/Archive
	ARCHIVEPATH=$WEBAPPSPATH/Archive
    #Create Archive folder in webapps
    
    if [ -d $WEBAPPSPATH ]
    then
        echo "/webapps is exists! Checking Jenkins!"
        JENKINNAME=$WEBAPPSPATH/jenkins.war
        if [ -f "$JENKINNAME" ]
		then
			JENKINSFILESIZE=${stat -c%s $JENKINNAME}
			if [ $JENKINSFILESIZE -le 0 ]
			then
				echo "Error: JENKINS file size is 0"
				exit 1
			else
				echo "Jenkins file exists! Please help to add version jenkins and move it to Archive!"
			fi
        else
            wget -O $JENKINNAME https://get.jenkins.io/war-stable/$jenkins_version/jenkins.war
			JENKINSFILESIZE=${stat -c%s $JENKINNAME}
			if [ $JENKINSFILESIZE -le 0 ]
			then
				echo "Error: JENKINS file size is 0"
				exit 1
			else
			cp $JENKINNAME $ARCHIVEPATH/jenkins-$jenkins_version.war
            fi
    else
        echo "No directory exists!"
    fi
    #JENKINS
    
    #START TOMCAT SERVICE
    export BUILD_ID=dontKillMe
    sh $TOMCATPATH/bin/startup.sh
    #START TOMCAT SERVICE
	
	#Remove war file after move to archive
	rm -f $JENKINNAME
	#Remove war file after move to archive
fi
