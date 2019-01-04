#!/bin/sh

###########################################################
# This is a simple demo tool to illustrate interacting with
# the APIC API using shell and curl.
###########################################################

# Usage:
#  bp-config.sh enable|disable


###########################################################
# Configuration 
###########################################################


# Set your APIC username, password, and hostname/IP of controller
#USER=bullwinkle
#PASS=watch_me_pull_a_rabbit_out_of_my_hat!
#HOST=1.2.3.4


# Reference https://unofficialaciguide.com/2018/11/29/aci-best-practice-configurations/
# Set these to YES if you want to configure (enable/disable).
# Set to anything else to IGNORE (do nothing to) the setting.
# This script will enable/disable all the YES settings.

MCP=NO
IP_AGING=NO
EP_LOOP_PROTECTION=NO
EP_DETECTION=YES
PORT_TRACKING=NO
COOP_GROUP_POLICY=NO
BFD_FABRIC_INT=NO
PRESERVE_COS=NO


# CURL options
# Change these if necessary.
#
# -s = silent (no status output)
# -k = accept untrusted certificates (self-signed, etc)

# You probably DON'T want to change these.
# -X POST = HTTP POST method 
# -H "Content-Type: application/xml" = We're using XML data here, not JSON.

CURL_OPTS='-s -k -H "Content-Type: application/xml" -X POST'


# COOKIE is the cookie file in the local/current working directiry. 
# You can change COOKIE to a path/file if the current directory is not writable.

COOKIEFILE="COOKIE"
#COOKIEFILE="/tmp/cookie-file"


# STOP! There is no more configuration to edit.
# You shouldn't need to edit anything below, unless you're tweaking/improving/etc the script itself.




###########################################################
# Variables
###########################################################

export DATE=$(date +%Y%m%d)

###########################################################
# Functions
###########################################################

#() {
#	if [[ $ = "YES" ]]; then
#        	echo "Configuring! "
#	else
#      		echo "setting ignored. Change to YES to enable/disable setting."
#	fi
#}


auth() {
	curl CURL_OPTS http://$HOST/api/mo/aaaLogin.xml -d "<aaaUser name=$USER pwd=$PASS/>" -c COOKIE
}



usage() {
        echo "Usage:"
        echo "bp-config.sh enable"
        echo "bp-config.sh disable"
} 

enable_mcp() {
        if [[ $MCP = "YES" ]]; then
		echo "Enabling MCP."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/mcpInstP-default.xml -d '<mcpInstPol adminSt="enabled" annotation="" ctrl="pdu-per-vlan" descr="" dn="uni/infra/mcpInstP-default" initDelayTime="180" loopDetectMult="2" loopProtectAct="port-disable" name="default" nameAlias="" ownerKey="" ownerTag="" txFreq="2" txFreqMsec="0"/>' -b $COOKIEFILE
        else
               echo "Skipping MCP. Change to YES to enable/disable setting."
        fi	
}

disable_mcp() {
	if [[ $MCP = "YES" ]]; then
              	echo "Disabling MCP."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/mcpInstP-default.xml -d '<mcpInstPol adminSt="disabled"/>' -b $COOKIEFILE
        else
               echo "Skipping MCP. Change to YES to enable/disable setting."
        fi
}

enable_ipage() {
	if [[ $IP_AGING  = "YES" ]]; then
               	echo "Enabling IP Aging."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/ipAgingP-default.xml -d '<epIpAgingP adminSt="enabled"/>'  -b $COOKIEFILE
        else
               	echo "Skipping IP Aging. Change to YES to enable/disable setting."
        fi
}

disable_ipage() {
	if [[ $IP_AGING  = "YES" ]]; then
                echo "Disabling IP Aging"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/ipAgingP-default.xml -d '<epIpAgingP adminSt="disabled"/>' -b $COOKIEFILE
        else
               echo "Skipping IP Aging. Change to YES to enable/disable setting."
        fi
}

enable_eploop() {
	if [[ $EP_LOOP_PROTECTION  = "YES" ]]; then
               	echo "Enabling Loop Protection! "
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/epLoopProtectP-default.xml -d '<epLoopProtectP action="" adminSt="enabled" annotation="" loopDetectIntvl="60" loopDetectMult="4" />' -b $COOKIEFILE
        else
               echo "Skipping Loop Protection.. Change to YES to enable/disable setting."
        fi
}

disable_eploop() {
        if [[ $EP_LOOP_PROTECTION  = "YES" ]]; then
                echo "Disabling Loop Protection."
		curl $CURL_OPTS -X POST https://$HOST/api/node/mo/uni/infra/epLoopProtectP-default.xml -d '<epLoopProtectP action="" adminSt="disabled" annotation="" loopDetectIntvl="60" loopDetectMult="4" />' -b $COOKIEFILE
        else
               echo "Skipping Loop Protection. Change to YES to enable/disable setting."
        fi
}

enable_epdetect() {
        if [[ $EP_DETECTION  = "YES" ]]; then
                echo "Enabling IP Learning."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/settings.xml -d '<infraSetPol enforceSubnetCheck="yes" unicastXrEpLearnDisable="yes"/>' -b $COOKIEFILE
        else
               echo "Skipping IP Learning. Change to YES to enable/disable setting."
        fi
}

disable_epdetect() {
        if [[ $EP_DETECTION  = "YES" ]]; then
                echo "Disabling IP Learning! "
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/settings.xml -d '<infraSetPol enforceSubnetCheck="no" unicastXrEpLearnDisable="no"/>' -b $COOKIEFILE
        else
               echo "Skipping IP Learning. Change to YES to enable/disable setting."
        fi
}

enable_porttrack() {
        if [[ $PORT_TRACKING   = "YES" ]]; then
                echo "Enabling Port Tracking! "
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/trackEqptFabP-default.xml -d '<infraPortTrackPol adminSt="on"/>' -b $COOKIEFILE 
        else
               echo "Skipping Port Tracking. Change to YES to enable/disable setting."
        fi	
}

disable_porttrack() {
        if [[ $PORT_TRACKING   = "YES" ]]; then
                echo "Disabling Port Tracking! "
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/trackEqptFabP-default.xml -d '<infraPortTrackPol adminSt="off"/>' -b cookie
        else
               echo "Skipping Port Tracking. Change to YES to enable/disable setting."
        fi
}

enable_coop() {
        if [[ $COOP_GROUP_POLICY   = "YES" ]]; then
                echo "Enabling COOP Group Policy."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/pol-default.xml -d '<coopPol type="strict"/>' -b $COOKIEFILE
        else
               echo "Skipping COOP Group Policy. Change to YES to enable/disable setting."
        fi

	
}

disable_coop() {
       if [[ $COOP_GROUP_POLICY   = "YES" ]]; then
                echo "Disabling COOP Group Policy."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/pol-default.xml -d '<coopPol type="compatible"/>' -b $COOKIEFILE
        else
               echo "Skipping COOP Group Policy. Change to YES to enable/disable setting."
        fi

}

enable_bfd() {
        if [[ $BFD_FABRIC_INT   = "YES" ]]; then
                echo "Enabling BFD Fabric Interfaces."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/l3IfP-default.xml -d '<l3IfPol bfdIsis="enabled"/>' -b $COOKIEFILE
        else
                echo "Skipping BFD Fabric Interface. Change to YES to enable/disable setting."
        fi

}

disable_bfd() {
        if [[ $BFD_FABRIC_INT   = "YES" ]]; then
                echo "Disabling BFD Fabric Interfaces"
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/fabric/l3IfP-default.xml -d '<l3IfPol bfdIsis="disabled"/>' -b $COOKIEFILE
        else
               echo "Skipping BFD Fabric Interface. Change to YES to enable/disable setting."
        fi
}

enable_preservecos() {
        if [[ $PRESERVE_COS   = "YES" ]]; then
               echo "Enabling Preserve COS."
	       curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/qosinst-default.xml -d '<qosInstPol name="default" ctrl="dot1p-preserve"></qosInstPol>' -b $COOKIEFILE
        else
               echo "Skipping Preserve COS. Change to YES to enable/disable setting."
        fi

}

disable_preservecos() {
        if [[ $PRESERVE_COS   = "YES" ]]; then
                echo "Disabling Preserve COS."
		curl $CURL_OPTS https://$HOST/api/node/mo/uni/infra/qosinst-default.xml -d '<qosInstPol name="default" ctrl=""></qosInstPol>' -b $COOKIEFILE
        else
               echo "Skipping Preserve COS. Change to YES to enable/disable setting."
        fi
}

enable_all() {
	enable_mcp
	enable_ipage
	enable_eploop
	enable_eplearn
	enable_porttrack
	enable_coop
	enable_bfd
	enable_preservecos
}


disable_all() {
	disable_mcp
	disable_ipage
	disable_eploop
	disable_eplearn
	disable_porttrack
	disable_coop
	disable_bfd
	disable_preservecos
}

###########################################################
# Main
###########################################################

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
