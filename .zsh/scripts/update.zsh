#!/bin/zsh

#exit 0 if nothing happened or an update occurred but no installed packages received an update
#exit 1 if an update occurred and one or more packages need to be upgraded
#This script expects an empty file to exist with its last modified date set to the last time the
#package manager was updated. If this file does not exist it will assume an update is needed
#and create the file for next time. If the file does exist it will compare its timestamp
#with the timestamp of a temporary file that is discarded when the script finishes. The temporary
#file has a timestamp set to current time minus a configurable amount of time. Default is one day.


#Function that updates the homebrew package manager and returns 0 if no upgrades are needed or
#1 otherwise. Also checks outdated packages against pinned packages. If any outdated packages
#are not pinned an upgrade is required and the return value will reflect that.
#Pinned packages are packages that should not be automatically upgraded.
function update {
    brew update 2>&1 > /dev/null
    all_packages_pinned=0
    for outdated_package in $(brew outdated --quiet); do #iterate across outdated packages
        package_pinned=1
        for pinned_package in $(brew list --pinned); do
            if [ $outdated_package = $pinned_package ]; then #this outdated package is pinned, move on to the next
                package_pinned=0
                break
            fi
        done
        if [ $package_pinned = 1 ]; then #an outdated package is not pinned
            all_packages_pinned=1
            break
        fi
    done
    return $all_packages_pinned
}


old_file="${HOME}/.zsh/caches/lastupdate" #file with timestamp of when last update occurred
new_file="${HOME}/.zsh/caches/temp" #temp file used for time comparison
time_delta='1d' #maximum amount of time before an update is needed, set to one day
exit_status=0


if test ! -e $old_file; then #last update file did not exist, assume outdated
    touch $old_file #create the file for next time
    update
    exit_status=$?
else
    new_time=$(date -v "-$time_delta" '+%Y%m%d%H%M.%S') #create timestamp of now minus time_delta
    touch -t $new_time $new_file #create temp file with timestamp of new_time
    if [ $old_file -ot $new_file ]; then #if update has not occurred within time_delta
        update
        exit_status=$?
        touch $old_file #update timestamp of old_file to now
    fi
    rm $new_file #remove temp file
fi

exit $exit_status

