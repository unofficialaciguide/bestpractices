# Best Practices for Curling
A set of curl statements and shell script for Best Practice settings for the Cisco ACI APIC Controller.

Reference: 
- https://unofficialaciguide.com/2018/11/29/aci-best-practice-configurations/
- https://unofficialaciguide.com/2019/01/16/best-practices-for-curling/

Contents:
- best practices for curling.txt: A collection of curl statements to support Best Practices Recommendation. 
- bp-config.sh: a demo config script to configure recommended settings.

Requirements:
- A Unix-compatible system running BASH. 
- A text editor to adjust the configuration variables.

Installation:
- Copy bp-config.sh into $PATH of your choice on a Unix-compatible system. $HOME/bin, /usr/local/bin, or /opt/scripts/bin, etc. 
- Set the execute bits: chmod +x /path/to/bp-config.sh

Configuration: 
- Edit bp-config.sh and change the USER, PASS, and HOST variables to match your username, password, and controller hostname.
- Optional: edit the Settings Config variables to activate/deactivate the functions that enable/disable a given setting.
- Optional: set COOKIEFILE to a file in a writable directory (/tmp/cookie, $HOME/tmp, $HOME/cookie, etc)
- Optional: set the CURL_OPTS to match your environment. Defaults include -s (suppress status), and -k (accept insecure/self-signed certificates).

Execution: 
- Run "bp-config.sh" enable to enable all the recommended settings.
- Run "bp-config.sh" disable to disable all the recommended settings.


