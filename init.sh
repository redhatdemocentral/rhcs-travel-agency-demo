#!/bin/sh 
DEMO="Cloud JBoss BPM Travel Agency Demo"
AUTHORS="Niraj Patel, Shepherd Chengeta,"
AUTHORS2="Andrew Block, Eric D. Schabell"
PROJECT="git@github.com:redhatdemocentral/rhcs-travel-agency-demo.git"
SRC_DIR=./installs
BPMS=jboss-bpmsuite-installer-6.2.0.BZ-1299002.jar
EAP=jboss-eap-6.4.0-installer.jar
EAP_PATCH=jboss-eap-6.4.4-patch.zip

# wipe screen.
clear 

echo
echo "####################################################################"
echo "##                                                                ##"   
echo "##  Setting up the ${DEMO}             ##"
echo "##                                                                ##"   
echo "##                                                                ##"   
echo "##     ####  ####   #   #      ### #   # ##### ##### #####        ##"
echo "##     #   # #   # # # # #    #    #   #   #     #   #            ##"
echo "##     ####  ####  #  #  #     ##  #   #   #     #   ###          ##"
echo "##     #   # #     #     #       # #   #   #     #   #            ##"
echo "##     ####  #     #     #    ###  ##### #####   #   #####        ##"
echo "##                                                                ##" 
echo "##                       ###   #### #####                         ##"
echo "##                  #   #   # #     #                             ##"
echo "##                 ###  #   #  ###  ###                           ##"
echo "##                  #   #   #     # #                             ##"
echo "##                       ###  ####  #####                         ##"
echo "##                                                                ##"  
echo "##                                                                ##"   
echo "##  brought to you by,                                            ##"   
echo "##                     ${AUTHORS}            ##"
echo "##                       ${AUTHORS2}           ##"
echo "##                                                                ##"   
echo "##  ${PROJECT}  ##"
echo "##                                                                ##"   
echo "####################################################################"
echo

# make some checks first before proceeding.	
command -v oc -v >/dev/null 2>&1 || { echo >&2 "OpenShift command line tooling is required but not installed yet... download here:
https://developers.openshift.com/managing-your-applications/client-tools.html"; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
	echo Product sources are present...
	echo
else
	echo Need to download $EAP package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$EAP_PATCH ] || [ -L $SRC_DIR/$EAP_PATCH ]; then
	echo Product patches are present...
	echo
else
	echo Need to download $EAP_PATCH package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$BPMS ] || [ -L $SRC_DIR/$BPMS ]; then
		echo Product sources are present...
		echo
else
		echo Need to download $BPMS package from the Customer Portal 
		echo and place it in the $SRC_DIR directory to proceed...
		echo
		exit
fi

echo "OpenShift commandline tooling is installed..."
echo 
echo "Loging into OSE..."
echo
oc login 10.1.2.2:8443 --password=admin --username=admin

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc login' command!
	exit
fi
						
echo
echo "Creating a new project..."
echo
oc new-project rhcs-travel-agency-demo 
						
echo
echo "Setting up a new build..."
echo
oc new-build "jbossdemocentral/developer" --name=rhcs-travel-agency-demo --binary=true
						
if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc new-build' command!
	exit
fi
												
echo
echo "Importing developer image..."
echo
oc import-image developer
												
if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc import-image' command!
	exit
fi
																		
echo
echo "Starting a build, this takes some time to upload all of the product sources for build..."
echo
oc start-build rhcs-travel-agency-demo --from-dir=. --follow=true
																		
if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc start-build' command!
	exit
fi
																								
echo
echo "Creating a new application..."
echo
oc new-app rhcs-travel-agency-demo
																								
if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc new-app' command!
	exit
fi
																														
echo
echo "Creating an externally facing route by exposing a service..."
echo
oc expose service rhcs-travel-agency-demo --hostname=rhcs-travel-agency-demo.10.1.2.2.xip.io
																														
if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc expose service' command!
	exit
fi

echo
echo "=================================================================================="
echo "=                                                                                ="
echo "=  Login to start exploring the Travel Agency project:                           ="
echo "=                                                                                ="
echo "=    http://rhcs-travel-agency-demo.10.1.2.2.xip.io/business-central             ="
echo "=                                                                                ="
echo "=    [ u:erics / p:jbossbpm1! ]                                                  ="
echo "=                                                                                ="
echo "=                                                                                ="
echo "=  Access the online Travel Agnecy booking web application at:                   ="
echo "=                                                                                ="
echo "=    http://rhcs-travel-agency-demo.10.1.2.2.xip.io/external-client-ui-form-1.0  ="
echo "=                                                                                ="
echo "=                                                                                ="
echo "=  Note: it takes a few minutes to expose the service...                         ="
echo "=                                                                                ="
echo "=================================================================================="

