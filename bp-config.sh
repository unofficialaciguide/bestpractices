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


# Set your APIC username, password, and hostname/IP of controller
#USER=bullwinkle
#PASS=watch_me_pull_a_rabbit_out_of_my_hat!
#HOST=1.2.3.4


# Reference https://unofficialaciguide.com/2018/11/29/aci-best-practice-configurations/
# Set these to YES if you want to configure (enable/disable).
# Set to anything else to IGNORE (do nothing to) the setting.
# This script will enable/disable all the YES settings.

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

#() {
#	if [[ $ = "YES" ]]; then
#        	echo "Configuring! "
#	else
#      		echo "setting ignored. Change to YES to enable/disable setting."
#	fi
#}


auth() {
	curl $CURL_OPTS http://$HOST/api/mo/aaaLogin.xml -d "<aaaUser name=$USER pwd=$PASS/>" -c $COOKIEFILE > /dev/null
}



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


skip() {
	echo "$OPTION setting not configured. To enable this action, change $OPTION to \"yes\"". 
	echo "Skipping..."
	return 1
}


##############################################################################
### Mis-cabling Protocol
##############################################################################

enable_mcp() {
	if [ $MCP = "YES" ]; then 
		echo "Enabling MCP setting."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/mcpInstP-default.xml -d '<mcpInstPol adminSt="enabled" annotation="" ctrl="pdu-per-vlan" descr="" dn="uni/infra/mcpInstP-default" initDelayTime="180" loopDetectMult="2" loopProtectAct="port-disable" name="default" nameAlias="" ownerKey="" ownerTag="" txFreq="2" txFreqMsec="0"/>' -b $COOKIEFILE
	else	
		OPTION="MCP" 
		skip 
	fi
}


disable_mcp() {
	if [ $MCP = "YES" ]; then 
		echo "Disabling MCP setting."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/mcpInstP-default.xml -d '<mcpInstPol adminSt="disabled"/>' -b $COOKIEFILE
	else	
		OPTION="MCP"
		skip 
	fi
}


##############################################################################
### Disable Remote Endpoint Learning 
### Enforce Subnet Check
##############################################################################

enable_rel_esc() {
	if [ $REL_ESC = "YES" ]; then
		echo "Activating \"Disable Remote Endpoint Learning\" and \"Enforce Subnet Check\""
		curl $CURL_OPTS  https://$HOST/api/node/mo/uni/infra/settings.xml -d '<infraSetPol enforceSubnetCheck="yes" unicastXrEpLearnDisable="yes"/>' -b $COOKIEFILE
	else
		OPTION="REL_ESC"
		skip
	fi
}


disable_rel_esc() {
	if [ $REL_ESC = "YES" ]; then
		echo "Dectivating the \"Disable Remote Endpoint Learning\" and \"Enforce Subnet Check\""
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/settings.xml -d '<infraSetPol enforceSubnetCheck="no" unicastXrEpLearnDisable="no"/>' -b $COOKIEFILE
	else   
		OPTION="REL_ESC"
		skip
	fi
}



##############################################################################
### Endpoint Loop Detection 
##############################################################################

enable_eploop() {
	if [[ $EP_LOOP_DETECTION = "YES" ]]; then
		echo "Activating Endpoint Loop Protection"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/epLoopProtectP-default.xml -d '<epLoopProtectP action="" adminSt="enabled" annotation="" loopDetectIntvl="60" loopDetectMult="4" />' -b $COOKIEFILE
	else
		OPTION="EP_LOOP_PROTECTION"
		skip
	fi
}

disable_eploop() {
	if [[ $EP_LOOP_DETECTION = "YES" ]]; then
		echo "Disabling Loop Protection."
		curl $CURL_OPTS -X POST https://$HOST/api/node/mo/uni/infra/epLoopProtectP-default.xml -d '<epLoopProtectP action="" adminSt="disabled" annotation="" loopDetectIntvl="60" loopDetectMult="4" />' -b $COOKIEFILE
	else
		OPTION="EP_LOOP_PROTECTION"
		skip
	fi
}

##############################################################################
### Enable IP Aging
##############################################################################


enable_ipaging() {
	if [[ $IP_AGING = "YES" ]]; then
		echo "Activating IP Aging"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/ipAgingP-default.xml -d '<epIpAgingP adminSt="enabled"/>' -b $COOKIEFILE
	else
		OPTION="IP_AGING"
		skip
	fi
}

disable_ipaging() {
	if [[ $IP_AGING = "YES" ]]; then
		echo "Deactivating IP Aging" 
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/ipAgingP-default.xml -d '<epIpAgingP adminSt="disabled"/>' -b $COOKIEFILE
	else
		OPTION="IP_AGING"
		skip
	fi
}

##############################################################################
### Rogue Endpoint Detection
##############################################################################

enable_red() {
        if [[ $ROGUE_EP_DETECTION = "YES" ]]; then
                echo "Activating Rogue Endpoint Detection"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/epCtrlP-default.xml -d '<epControlP adminSt="enabled" rogueEpDetectIntvl="30" rogueEpDetectMult="6"/>' -b $COOKIEFILE
        else
                OPTION="ROGUE_EP_DETECTION"
                skip
        fi
}

disable_red() {
        if [[ $ROGUE_EP_DETECTION = "YES" ]]; then
                echo "Deactivating Rogue Endpoint Detection"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/epCtrlP-default.xml -d '<epControlP adminSt="disabled"/>' -b $COOKIEFILE
        else
                OPTION="ROGUE_EP_DETECTION"
                skip
        fi
}

##############################################################################
### Strict COOP Group Policy
##############################################################################

enable_coop() {
        if [[ $COOP_GROUP_POLICY = "YES" ]]; then
                echo "Activating Strict COOP Group Policy"
		curl $CURL_OPTS  https://$HOST/api/node/mo/uni/fabric/pol-default.xml -d '<coopPol type="strict"/>' -b $COOKIEFILE
        else
                OPTION="COOP_GROUP_POLICY"
                skip
        fi
}

disable_coop() {
        if [[ $COOP_GROUP_POLICY = "YES" ]]; then
                echo "Deactivating Strict COOP Group Policy"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/pol-default.xml -d '<coopPol type="compatible"/>' -b $COOKIEFILE
        else
                OPTION="COOP_GROUP_POLICY"
                skip
        fi
}

##############################################################################
### BFD For Fabric Facing Interfaces
##############################################################################

enable_bfd() {
        if [[ $BFD_FABRIC_INT = "YES" ]]; then
                echo "Activating BFD for Fabric Facing Interfaces"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/l3IfP-default.xml -d '<l3IfPol bfdIsis="enabled"/>' -b $COOKIEFILE
        else
                OPTION="BFD_FABRIC_INT"
                skip
        fi
}

disable_bfd() {
        if [[ $BFD_FABRIC_INT = "YES" ]]; then
                echo "Deactivating BFD for Fabric Facing Interfaces"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/l3IfP-default.xml -d '<l3IfPol bfdIsis="disabled"/>' -b $COOKIEFILE
        else
                OPTION="BFD_FABRIC_INT"
                skip
        fi
}

  
##############################################################################
### Preserve COS Through ACI Fabric
##############################################################################


enable_cos() {
        if [[ $PRESERVE_COS == "YES" ]]; then
                echo "Activating Preserve COS through the ACI Fabric."
		curl $CURL_OPTS  https://$HOST/api/node/mo/uni/infra/qosinst-default.xml -d '<qosInstPol name="default" ctrl="dot1p-preserve"></qosInstPol>' -b $COOKIEFILE 
        else
                OPTION="PRESERVE_COS"
                skip
        fi
}

disable_cos() {
        if [[ $PRESERVE_COS == "YES" ]]; then
                echo "Deactivating Preserve COS through the ACI Fabric."
		curl $CURL_OPTS  https://$HOST/api/node/mo/uni/infra/qosinst-default.xml -d '<qosInstPol name="default" ctrl=""></qosInstPol>' -b $COOKIEFILE 
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
                echo "Activating Preserve COS through the ACI Fabric."
        else    
                OPTION="PORT_TRACKING"
                skip
        fi
}

disable_porttrack() {
        if [[ $PORT_TRACKING == "YES" ]]; then
                echo "Deactivating Preserve COS through the ACI Fabric."
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
