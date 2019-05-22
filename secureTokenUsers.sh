#!/bin/bash
## v1.5
## A big thank you to Lionel Gruenberg for writing the UUID array building and loops, essentially the bones of this script.
## Credit also to Boris42 from StackExchange for syntax for sending data to PlistBuddy as a variable.
##
## This EA is designed to reliably identify and report all users on macOS 10.13 and above that have a SecureToken.  This is done using the 'diskutil apfs listcryptousers /' command rather than with the sysadminctl binary as this has been known to report falsely in certain situations.  The device must be running at least macOS 10.13.0 and the boot volume being APFS.  If these criteria are not satisfied the EA will finish and report that the device was ineligible.

## In Jamf Pro this EA can be used as a Smart Computer Group or Advanced Computer Search criteria with the 'like' operator to report on whether certain accounts have a SecureToken, such as your management account or otherwise IT local administrator.

## Declaring the required variables
# Operating system version to ensure the device is eligible
osVersion=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')

# Get boot volume information for APFS checking
bootVolumeInfo=$(/usr/sbin/diskutil info -plist /)

# Check if the boot volume is APFS
isAPFS=$(/usr/libexec/PlistBuddy -c "Print :FilesystemType" /dev/stdin <<< $bootVolumeInfo)

###### EA commences here
# Check if the device meets the required criteria of minimum OS version, APFS boot volume and encryption status.
if [[ $osVersion -ge 13 ]] && [[ $isAPFS == "apfs" ]]; then

# Create temporary plist file of user UUIDs with a SecureToken
    stUsers=$(/usr/sbin/diskutil apfs listcryptousers / -plist)

# Create an array of all user UUIDs from the plist data we saved as a variable just above
    index=-1
    uuidArray=()
    userArray=()
    while [[ $? == 0 ]];do
        ((index++))
        uuidArray+=($(/usr/libexec/PlistBuddy -c "print Users:$index:APFSCryptoUserUUID" /dev/stdin <<< $stUsers 2> /dev/null))
    done

# Loop through the array of UUIDs and identify the Mac user account belonging to each of them
    for uuid in ${uuidArray[@]};do
        userArray+=($(/usr/bin/dscl . list /Users GeneratedUID | /usr/bin/awk '/'$uuid'/{print$1}'))
    done

# Report the usernames back as the EA result
    /bin/echo "<result>"${userArray[@]}"</result>"

else
# Report back that the device is ineligible due to either being not macOS 10.13+, not running APFS or not being encrypted.
    /bin/echo "<result>Device Not Eligible</result>"
fi
