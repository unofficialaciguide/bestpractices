#!/bin/sh

##############################################################################
# This is a simple demo tool to illustrate interacting with
# the APIC API using shell and curl.
##############################################################################

# Usage:
#  bp-config.sh enable|disable


##############################################################################
# Configuration 
##############################################################################

# AUTH INFO
# Set your APIC username, password, and hostname/IP of controller

#USER=bullwinkle
#PASS=watch_me_pull_a_rabbit_out_of_my_hat!
#HOST=1.2.3.4
#HOST=mycontroller.mycompany.com

USER=
PASS=
HOST=

# Settings config

# Set these to YES if you want to configure (enable/disable).
# Set to anything else to IGNORE (do nothing to) the setting.
# This script will Activate or Deactivate all the YES settings.
# Reference https://unofficialaciguide.com/2018/11/29/aci-best-practice-configurations/

export MCP=YES
export REL_ESC=YES
export EP_LOOP_DETECTION=YES
export IP_AGING=YES
export ROGUE_EP_DETECTION=YES
export COOP_GROUP_POLICY=YES
export BFD_FABRIC_INT=YES
export PRESERVE_COS=YES
#export PORT_TRACKING=YES


# CURL options
# Change these if necessary.
#
# -s = silent (no status output)
# -k = accept untrusted certificates (self-signed, etc)

# Don't change these.
# -X POST = HTTP POST method 
# -H "Content-Type: application/xml" = We're using XML data here, not JSON.

CURL_OPTS='-s -k -H "Content-Type: application/xml" -X POST'


# COOKIE is the cookie file in the local/current working directiry. 
# You can change COOKIE to a path/file if the current directory is not writable.

COOKIEFILE="COOKIE"
#COOKIEFILE="/tmp/cookie-file"


# STOP! There is no more configuration to edit.
# You shouldn't need to edit anything below, unless you're tweaking/improving/etc the script itself.




##############################################################################
# Variables
##############################################################################

export DATE=$(date +%Y%m%d)

##############################################################################
# Functions
##############################################################################

# The auth function passes the username/password to authenticate and set the cookie/token.

auth() {
	curl $CURL_OPTS http://$HOST/api/mo/aaaLogin.xml -d "<aaaUser name=$USER pwd=$PASS/>" -c $COOKIEFILE > /dev/null
}



# A simple usage function if the script is called without arguments.

usage() {
	echo " "
	echo "This is a simple demo script to enable/disable specific settings based on the Best Practices article"
	echo "at http://unofficialaciguide.com/2018/11/29/aci-best-practice-configurations/"
	echo " "
	echo "For the full list of options enabled/disabled or to read a walk-thru of this script, "
	echo "please see [ insert new link ]. "
	echo " "
	echo "Usage:"
	echo "bp-config.sh enable"
	echo "bp-config.sh disable"
} 


# A simple function to inform the user that a particular setting is not configured,
# so the API curl command will not be executed.

skip() {
	echo "$OPTION setting not configured. To enable this action, change $OPTION to \"yes\"". 
	echo "Skipping..."
	return 1
}


# Each function below does the following:
#  - Tests the variable/setting to determine if it should run or not. 
#  - If set to YES, run the following curl command. 
#  - If not set to YES, then set the OPTION variable and run the "skip" function above. 
#
# For each ACI setting, there will be a separate enable/disable function. 
# You could probably test for the positional parameter (enable/disable) and combine the two functions 
# into one, but this is a simpler approach for a demonstration script.

 
##############################################################################
### Mis-cabling Protocol
##############################################################################

# To verify this setting in the GUI, go to 
# Fabric > Access Policies > Global Policies > MCP Instance Policy Default

enable_mcp() {
	if [ $MCP = "YES" ]; then 
		echo "Activating MisCabling Protocol"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/mcpInstP-default.xml -d '<mcpInstPol adminSt="enabled" annotation="" ctrl="pdu-per-vlan" descr="" dn="uni/infra/mcpInstP-default" initDelayTime="180" loopDetectMult="2" loopProtectAct="port-disable" name="default" nameAlias="" ownerKey="" ownerTag="" txFreq="2" txFreqMsec="0"/>' -b $COOKIEFILE  > /dev/null
	else	
		OPTION="MCP" 
		skip 
	fi
}


disable_mcp() {
	if [ $MCP = "YES" ]; then 
		echo "Deactivating MisCabling Protocol"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/mcpInstP-default.xml -d '<mcpInstPol adminSt="disabled"/>' -b $COOKIEFILE > /dev/null
	else	
		OPTION="MCP"
		skip 
	fi
}


##############################################################################
### Disable Remote Endpoint Learning 
### Enforce Subnet Check
##############################################################################

# To verify these settings in the GUI, go to:
# System > System Settings > Fabric Wide Setting

enable_rel_esc() {
	if [ $REL_ESC = "YES" ]; then
		echo "Activating \"Disable Remote Endpoint Learning\" and \"Enforce Subnet Check\""
		curl $CURL_OPTS  https://$HOST/api/node/mo/uni/infra/settings.xml -d '<infraSetPol enforceSubnetCheck="yes" unicastXrEpLearnDisable="yes"/>' -b $COOKIEFILE > /dev/null
	else
		OPTION="REL_ESC"
		skip
	fi
}


disable_rel_esc() {
	if [ $REL_ESC = "YES" ]; then
		echo "Dectivating the \"Disable Remote Endpoint Learning\" and \"Enforce Subnet Check\""
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/settings.xml -d '<infraSetPol enforceSubnetCheck="no" unicastXrEpLearnDisable="no"/>' -b $COOKIEFILE > /dev/null
	else   
		OPTION="REL_ESC"
		skip
	fi
}



##############################################################################
### Endpoint Loop Detection 
##############################################################################

# To verify these settings, go to:
# Fabric > Access Policies > Global Policies > EP Loop Detection Policy

enable_eploop() {
	if [[ $EP_LOOP_DETECTION = "YES" ]]; then
		echo "Activating Endpoint Loop Protection"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/epLoopProtectP-default.xml -d '<epLoopProtectP action="" adminSt="enabled" annotation="" loopDetectIntvl="60" loopDetectMult="4" />' -b $COOKIEFILE > /dev/null
	else
		OPTION="EP_LOOP_PROTECTION"
		skip
	fi
}

disable_eploop() {
	if [[ $EP_LOOP_DETECTION = "YES" ]]; then
		echo "Deactivating Endpoint Loop Protection."
		curl $CURL_OPTS -X POST https://$HOST/api/node/mo/uni/infra/epLoopProtectP-default.xml -d '<epLoopProtectP action="" adminSt="disabled" annotation="" loopDetectIntvl="60" loopDetectMult="4" />' -b $COOKIEFILE > /dev/null
	else
		OPTION="EP_LOOP_PROTECTION"
		skip
	fi
}

##############################################################################
### Enable IP Aging
##############################################################################

# To verify this setting, go to:
# System > System Settings > Endpoint Control 
# IP Aging is on the right.

enable_ipaging() {
	if [[ $IP_AGING = "YES" ]]; then
		echo "Activating IP Aging"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/ipAgingP-default.xml -d '<epIpAgingP adminSt="enabled"/>' -b $COOKIEFILE > /dev/null
	else
		OPTION="IP_AGING"
		skip
	fi
}

disable_ipaging() {
	if [[ $IP_AGING = "YES" ]]; then
		echo "Deactivating IP Aging" 
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/ipAgingP-default.xml -d '<epIpAgingP adminSt="disabled"/>' -b $COOKIEFILE > /dev/null
	else
		OPTION="IP_AGING"
		skip
	fi
}

##############################################################################
### Rogue Endpoint Detection
##############################################################################

# To verify this setting, go to: 
# System > System Settings > Endpoint Controls > Rogue EP Control

enable_red() {
        if [[ $ROGUE_EP_DETECTION = "YES" ]]; then
                echo "Activating Rogue Endpoint Detection"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/epCtrlP-default.xml -d '<epControlP adminSt="enabled" rogueEpDetectIntvl="30" rogueEpDetectMult="6"/>' -b $COOKIEFILE > /dev/null
        else
                OPTION="ROGUE_EP_DETECTION"
                skip
        fi
}

disable_red() {
        if [[ $ROGUE_EP_DETECTION = "YES" ]]; then
                echo "Deactivating Rogue Endpoint Detection"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/epCtrlP-default.xml -d '<epControlP adminSt="disabled"/>' -b $COOKIEFILE > /dev/null
        else
                OPTION="ROGUE_EP_DETECTION"
                skip
        fi
}

##############################################################################
### Strict COOP Group Policy
##############################################################################

# To verify this setting, go to:
# System > System Settings > COOP Group

enable_coop() {
        if [[ $COOP_GROUP_POLICY = "YES" ]]; then
                echo "Activating Strict COOP Group Policy"
		curl $CURL_OPTS  https://$HOST/api/node/mo/uni/fabric/pol-default.xml -d '<coopPol type="strict"/>' -b $COOKIEFILE > /dev/null
        else
                OPTION="COOP_GROUP_POLICY"
                skip
        fi
}

disable_coop() {
        if [[ $COOP_GROUP_POLICY = "YES" ]]; then
                echo "Deactivating Strict COOP Group Policy"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/pol-default.xml -d '<coopPol type="compatible"/>' -b $COOKIEFILE > /dev/null
        else
                OPTION="COOP_GROUP_POLICY"
                skip
        fi
}

##############################################################################
### BFD For Fabric Facing Interfaces
##############################################################################

# To verify this setting, go to:
# Fabric > Fabric Policies > Policies > L3 Interface > default > BFD ISIS Policy Configuration

enable_bfd() {
        if [[ $BFD_FABRIC_INT = "YES" ]]; then
                echo "Activating BFD for Fabric Facing Interfaces"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/l3IfP-default.xml -d '<l3IfPol bfdIsis="enabled"/>' -b $COOKIEFILE > /dev/null
        else
                OPTION="BFD_FABRIC_INT"
                skip
        fi
}

disable_bfd() {
        if [[ $BFD_FABRIC_INT = "YES" ]]; then
                echo "Deactivating BFD for Fabric Facing Interfaces"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/l3IfP-default.xml -d '<l3IfPol bfdIsis="disabled"/>' -b $COOKIEFILE > /dev/null
        else
                OPTION="BFD_FABRIC_INT"
                skip
        fi
}

  
##############################################################################
### Preserve COS Through ACI Fabric
##############################################################################

# To verify this setting, go to:
# Fabric > Access Policies > Policies > Global > QOS Class > Preserve COS

enable_cos() {
        if [[ $PRESERVE_COS == "YES" ]]; then
                echo "Activating Preserve COS through the ACI Fabric."
		curl $CURL_OPTS  https://$HOST/api/node/mo/uni/infra/qosinst-default.xml -d '<qosInstPol name="default" ctrl="dot1p-preserve"></qosInstPol>' -b $COOKIEFILE > /dev/null
        else
                OPTION="PRESERVE_COS"
                skip
        fi
}

disable_cos() {
        if [[ $PRESERVE_COS == "YES" ]]; then
                echo "Deactivating Preserve COS through the ACI Fabric."
		curl $CURL_OPTS  https://$HOST/api/node/mo/uni/infra/qosinst-default.xml -d '<qosInstPol name="default" ctrl=""></qosInstPol>' -b $COOKIEFILE > /dev/null
        else
                OPTION="PRESERVE_COS"
                skip
        fi
}

##############################################################################
### Enable Port Tracking
##############################################################################

enable_porttrack() {
        if [[ $PORT_TRACKING == "YES" ]]; then 
                echo "Activating Port Tracking"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/trackEqptFabP-default.xml -d '<infraPortTrackPol adminSt="on"/>' -b $COOKIEFILE > /dev/null
        else    
                OPTION="PORT_TRACKING"
                skip
        fi
}

disable_porttrack() {
        if [[ $PORT_TRACKING == "YES" ]]; then
                echo "Deactivating Port Tracking"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/trackEqptFabP-default.xml -d '<infraPortTrackPol adminSt="off"/>' -b $COOKIEFILE > /dev/null
        else
                OPTION="PORT_TRACKING"
                skip
        fi
}

enable_all() {
	enable_mcp 
	enable_rel_esc
	enable_eploop
	enable_ipaging
	enable_red
	enable_coop
	enable_bfd
	enable_cos
	#enable_porttrack
}


disable_all() {
	disable_mcp
	disable_rel_esc
	disable_eploop
	disable_ipaging
	disable_red
	disable_coop
	disable_bfd
	disable_cos
	#disable_porttrack
}

##############################################################################
# Main
##############################################################################

if [[ $# -eq 0 ]] ; then
	usage
    	exit 1
fi

case $1 in 
	enable ) 	auth
			enable_all
			;;
	disable	)	auth	
			disable_all
			;;
	* )		usage
			exit 1
			;;
esac
