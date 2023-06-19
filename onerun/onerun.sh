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
	    TOMCATFILESIZE=$(stat -c%s $TOMCATFILE)
	    if [ $TOMCATFILESIZE -le 0 ]
	    then
		    echo "Error: TOMCAT tar file size is 0"
		    rm -f $TOMCATFILE
		    exit 1
	    else
		    echo "Tomcat file exists!"
	    fi
    else
	    echo "Tomcat is not exists. Downloading Tomcat"
    	    wget -O $TOMCATFILE https://dlcdn.apache.org/tomcat/tomcat-9/v$tomcat_version/bin/apache-tomcat-$tomcat_version.tar.gz
    	    TOMCATFILESIZE=$(stat -c%s $TOMCATFILE)
	    if [ $TOMCATFILESIZE -le 0 ]
	    then
		    echo "Error: TOMCAT tar file size is 0"
		    rm -f $TOMCATFILE
		    exit 1
	    else
		    echo "Download completed. Extracting Tomcat"
		    tar -xf $TOMCATFILE -C $TOMCATPATH --strip-components=1
	    fi
    fi

    TOMCATUSERFILE=$TOMCATPATH/conf/tomcat-users.xml
    CONTEXTFILE=$TOMCATPATH/webapps/manager/META-INF/context.xml
    CHMODCP=$TOMCATPATH/conf/context.xml
    
    if [ -f "$HOME/onerun/onerun/tomcat-users.xml" ]
    then
	    echo "Replace tomcat-users file"
	    cp $HOME/onerun/onerun/tomcat-users.xml $TOMCATUSERFILE
	    chown --reference=$CHMODCP $TOMCATUSERFILE
    else
	    echo "File is not exists!"
	    exit 1
    fi
    
    if [ -f "$HOME/onerun/onerun/context.xml" ]
    then
	    echo "Replace Context file"
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
    if [ -d $WEBAPPSPATH/Archive ]
    then
	    echo "Archived for Jenkins already created!"
    else
	    echo "Create Archive folder in webapps"
	    mkdir $WEBAPPSPATH/Archive
    fi
    
    ARCHIVEPATH=$WEBAPPSPATH/Archive
    #Create Archive folder in webapps
    
    if [ -d $WEBAPPSPATH ]
    then
        echo "/webapps is exists! Checking Jenkins!"
        JENKINSFILE=$WEBAPPSPATH/jenkins.war
        if [ -f "$JENKINSFILE" ]
	then
		JENKINSFILESIZE=$(stat -c%s $JENKINSFILE)
		if [ $JENKINSFILESIZE -le 0 ]
		then
			echo "Error: JENKINS file size is 0"
			rm -f $JENKINSFILE
			#reverse
			old_version_file=$ARCHIVEPATH/$(ls -t "$ARCHIVEPATH" | head -n 1)
                        if [ -f "$old_version_file" ]
                        then
                                echo "Reverse back to the old version jenkins in Archive"
                                cp $old_version_file $JENKINSFILE
                        else
                                echo "No file in Archive, aborted!"
                                exit $1
                        fi
			#reverse
		else
			echo "Jenkins file exists! Remove the exists one and download new file!"
			rm -f $JENKINSFILE
			echo "Downloading Jenkins"
			wget -O $JENKINSFILE https://get.jenkins.io/war-stable/$jenkins_version/jenkins.war
                	JENKINSFILESIZE=$(stat -c%s $JENKINSFILE)
                	if [ $JENKINSFILESIZE -le 0 ]
                	then
                        	echo "Error: JENKINS file size is 0"
                        	rm -f $JENKINSFILE
                        	#reverse
                        	old_version_file=$ARCHIVEPATH/$(ls -t "$ARCHIVEPATH" | head -n 1)
                        	if [ -f "$old_version_file" ]
                        	then
                                	echo "Reverse back to the old version jenkins in Archive"
                                	cp $old_version_file $JENKINSFILE
                        	else
                                	echo "No file in Archive, aborted!"
                                	exit $1
                        	fi
                        	#reverse
                	else
                        	echo "Copy Jenkins to Archive folder to backup"
                        	cp $JENKINSFILE $ARCHIVEPATH/jenkins-$jenkins_version.war
                	fi
		fi
	else
		echo "Jenkins file is not exists. Downloading Jenkins"
		wget -O $JENKINSFILE https://get.jenkins.io/war-stable/$jenkins_version/jenkins.war
    		JENKINSFILESIZE=$(stat -c%s $JENKINSFILE)
    		if [ $JENKINSFILESIZE -le 0 ]
    		then
    			echo "Error: JENKINS file size is 0"
			rm -f $JENKINSFILE
			#reverse
			old_version_file=$ARCHIVEPATH/$(ls -t "$ARCHIVEPATH" | head -n 1)
			if [ -f "$old_version_file" ]
			then
				echo "Reverse back to the old version jenkins in Archive"
				cp $old_version_file $JENKINSFILE
			else
				echo "No file in Archive, aborted!"
				exit $1
			fi
			#reverse
    		else
			echo "Copy Jenkins to Archive folder to backup"
    			cp $JENKINSFILE $ARCHIVEPATH/jenkins-$jenkins_version.war
		fi
	fi
    else
	echo "No directory exists! Missing file while extract Tomcat!"
	exit $1
    fi

    #JENKINS
    
    #START TOMCAT SERVICE
    echo "Start Tomcat service"
    export BUILD_ID=dontKillMe
    sh $TOMCATPATH/bin/startup.sh
    #START TOMCAT SERVICE

    #Remove war file after move to archive
    echo "Wait for Jenkins to deploy"
    JENKINSFOLDER=$WEBAPPSPATH/jenkins
    timeout_session=120

    while [ $timeout_session -gt 0 ];
    do
    	if [ -d $JENKINSFOLDER ]
    	then
	    JENKINSFOLDERSIZE=$(stat -c%s $JENKINSFOLDER) 
	    if [ $JENKINSFOLDERSIZE -gt 0 ]
	    then
		    echo "Jenkins has been deployed. Remove war file."
	    else
		    echo "Please wait a moment. Jenkins is deploying..."
	    fi
	    exit 1
	else
	    sleep 1
	fi
	timeout_session=$(expr $timeout_session - 1)
    done
fi
