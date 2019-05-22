#!/bin/bash
## v1.0
## Written by Matt Taylor

## This script is designed to be used as a Computer Extension Attribute in Jamf Pro to report on the installed version of Jamf Connect Login.  The version is read from the Info.plist file inside the JamfConnectLogin.bundle security agent plugin.
## Note: When configuring the Extension Attribute in Jamf Pro be sure to use Integer as the Data Type to allow for the most relevant smart criteria operators.

## DO NOTE CHANGE BELOW THIS LINE ##
# Declare a default variable value of Not Installed.
eaResult="Not Installed"

# Declare the path for the Info.plist file containing the version
jcLoginBundle="/Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle/Contents/Info.plist"

# Check if the file exists.  If so, declare the eaResult variable again but with the version string from the file.  If not, move on.
if [[ -f $jcLoginBundle ]]; then
    eaResult=$(/usr/bin/defaults read $jcLoginBundle CFBundleShortVersionString)
fi

# Echo the eaResult variable for the Extension Attribute value.
/bin/echo "<result>$eaResult</result>"
