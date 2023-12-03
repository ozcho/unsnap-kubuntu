#!/bin/bash

################################################################################
#                                                                              #
#                                                                              #
#         $$     $$                                                $$          #
#         $$     $$  $$$$$$$$$  $$         $$          $$$$$$$     $$          #
#         $$     $$  $$         $$         $$         $$     $$    $$          #
#         $$$$$$$$$  $$$$$$$$   $$         $$         $$     $$    $$          #
#         $$     $$  $$         $$         $$         $$     $$    $$          #
#         $$     $$  $$         $$         $$         $$     $$                #
#         $$     $$  $$$$$$$$$  $$$$$$$$$  $$$$$$$$$   $$$$$$$     $$          #
#                                                                              #
#                                                                              #
# This is a little helper script for Kubuntu™ users who want to get rid of     #
# and block Snap entirely (like Linux Mint does), including the Firefox Snap   #
# from 22.04 onwards.                                                          #
# It has been tested many times with Kubuntu™ 20.04, 22.04, 23.04 and 23.10.   #
#                                                                              #
# -> IMPORTANT:                                                                #
#    This script is best run after a fresh installation of Kubuntu™ but has    #
#    also been written to be run after a release-upgrade to the next main      #
#    Kubuntu™ version (e.g. from 22.04 LTS to 23.04).                          #
#    It should also work with a Kubuntu™ installation that has been used for a #
#    while - depending on your own system modifications - but BE AWARE THAT    #
#    ALL PROGRAMS YOU ADDITIONALLY INSTALLED AS SNAPS WILL BE REMOVED TOO!     #
#                                                                              #
#    A full upgrade of the system (either with Discover or in Konsole with     #
#    "sudo apt update && sudo apt full-upgrade && sudo snap refresh") AND a    #
#    reboot is strongly recommended prior to running this script.              #
#                                                                              #
#    It has been designed to be run in combination with the                    #
#    "reinstall_Snap_for_release-upgrade" script. It WILL ALSO REINSTALL       #
#    Firefox if that had been installed from the Mozilla Team PPA before you   #
#    ran the "reinstall_Snap_for_release-upgrade" script (prior to             #
#    release-upgrading to the next main Kubuntu™ version).                     #
#                                                                              #
# You will be asked for confirmation twice before the removal of Snaps and     #
# snapd is started and APT pinning to block future installation of Snap is     #
# applied - and if you answer "n" or "N" no changes at all are made to your    #
# system.                                                                      #
#                                                                              #
# For some more information about what is done in detail see the comments      #
# within this script.                                                          #
#                                                                              #
# My scripts are in no way associated with Canonical™, Ubuntu™ or Kubuntu™.    #
# This script comes with ABSOLUTELY NO WARRANTY OF ANY KIND.                   #
# It may be used, shared, copied and modified freely.                          #
#                                                                              #
# You can download my scripts from here: https://gitlab.com/scripts94          #
#                                                                              #
# I hope you find the script useful! Yours respectfully, Schwarzer Kater       #
#                                                                              #
################################################################################

versionnr="1.1.3"

########
## During this session let's make sure no "exotic" or interfering aliases are
## set for commands used in this script
########
unalias clear 2> /dev/null
unalias echo 2> /dev/null
unalias read 2> /dev/null
unalias command 2> /dev/null
unalias snap 2> /dev/null
unalias grep 2> /dev/null
unalias true 2> /dev/null
unalias sudo 2> /dev/null
unalias systemctl 2> /dev/null
unalias pkcon 2> /dev/null
unalias apt-get 2> /dev/null
unalias dpkg 2> /dev/null
unalias test 2> /dev/null
unalias rm 2> /dev/null
unalias tee 2> /dev/null
unalias add-apt-repository 2> /dev/null
unalias reboot 2> /dev/null

########
## Display purpose of this script
########
clear
echo -e "########"
echo -e "## This is a little helper script for Kubuntu™ users who want to get rid of"
echo -e "## and block Snap entirely (like Linux Mint does), including the Firefox Snap"
echo -e "## from 22.04 onwards."
echo -e "## It has been tested many times with Kubuntu™ 20.04, 22.04, 23.04 and 23.10."
echo -e "##"
echo -e "## -> IMPORTANT:"
echo -e "##    This script is best run after a fresh installation of Kubuntu™ but has"
echo -e "##    also been written to be run after a release-upgrade to the next main"
echo -e "##    Kubuntu™ version (e.g. from 22.04 LTS to 23.04)."
echo -e "##    It should also work with a Kubuntu™ installation that has been used for a"
echo -e "##    while - depending on your own system modifications - but BE AWARE THAT"
echo -e "##    ALL PROGRAMS YOU ADDITIONALLY INSTALLED AS SNAPS WILL BE REMOVED TOO!"
echo -e "##    A full upgrade of the system (either with Discover or in Konsole with"
echo -e "##    \"sudo apt update && sudo apt full-upgrade && sudo snap refresh\") AND a"
echo -e "##    reboot is strongly recommended prior to running this script."
echo -e "##    It has been designed to be run in combination with the"
echo -e "##    \"reinstall_Snap_for_release-upgrade\" script. It WILL ALSO REINSTALL"
echo -e "##    Firefox if that had been installed from the Mozilla Team PPA before you"
echo -e "##    ran the \"reinstall_Snap_for_release-upgrade\" script (prior to"
echo -e "##    release-upgrading to the next main Kubuntu™ version)."
echo -e "##"
echo -e "## You will be asked for confirmation twice before the removal of Snaps and"
echo -e "## snapd is started and APT pinning to block future installation of Snap is"
echo -e "## applied - and if you answer \"n\" or \"N\" no changes at all are made to your"
echo -e "## system."
echo -e "## For some more information about what is done in detail see the comments"
echo -e "## within the script itself."
echo -e "##"
echo -e "## This script comes with ABSOLUTELY NO WARRANTY OF ANY KIND."
echo -e "## It may be used, shared, copied and modified freely."
echo -e "##"
echo -e "## I hope you find the script useful! Yours respectfully, Schwarzer Kater"
echo -e "########\n"
read -p "Press [Enter] to continue, press [Ctrl] [c] to exit. "

########
## Remove the Firefox Snap, snapd and additionally installed Snaps entirely,
## remove remaining Snap support libraries/tools, remove remaining Snap
## directories, block future installation of Snap by APT pinning like Linux Mint
## does, re-enable the Mozilla Team PPA (if it had been enabled before running
## the "reinstall_Snap_for_release-upgrade script) and reinstall Firefox from
## there (if it had been installed before running the
## "reinstall_Snap_for_release-upgrade" script).
########
rmffsnap=0
inmtppa=0
inffpin=0
inmtff=0
rmsnap=0

echo -e "\n########\n## Do you want to remove and block Snap entirely from Kubuntu™?"
if command -v snap &> /dev/null && snap list 2> /dev/null | grep -i "^core" &> /dev/null && snap list firefox &> /dev/null
then
    # Warn about installed Snaps including the Firefox Snap that are to be removed
    echo -e "## (Including the Firefox Snap and all additional Snaps you may have installed.)\n## The following Snaps WILL BE REMOVED (\"core…\", \"bare\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
elif command -v snap &> /dev/null && snap list 2> /dev/null | grep -i "^core" &> /dev/null && ! snap list firefox &> /dev/null
then
    # Warn about installed Snaps that are to be removed
    echo -e "## (Including all additional Snaps you may have installed.)\n## The following Snaps WILL BE REMOVED (\"core…\", \"bare\", etc. are no actual\n## programs you have installed but just Snap \"support stuff\") :\n########\n" && snap list && echo
elif command -v snap &> /dev/null && ! snap list 2> /dev/null | grep -i "^core" &> /dev/null
then
    # Tell that snapd is to be removed
    echo -e "## No Snaps seem to be installed, but snapd WILL BE REMOVED.\n########"
else
    echo -e "########"
fi

while true
do
    read -p "[y/n] " answer
    if [[ "${answer}" = [Yy] ]]
    then
        # Only continue if snapd is installed
        if command -v snap &> /dev/null
        then
            # Ask for confirmation
            echo -e "\n########\n## Are you sure you want to get rid of and block Snap?\n########"
            while true
            do
                read -p "[y/n] " confirm
                if [[ "${confirm}" = [Yy] ]]
                then
                    # Uninstall the Firefox Snap first, if it is installed
                    if snap list firefox &> /dev/null ; then echo -e "\n########\n## -> Removing the Firefox Snap …\n########\n" && sudo snap remove --purge firefox && rmffsnap=1 ; fi

                    # Uninstall the Chromium Snap first, if it is installed
                    if snap list chromium &> /dev/null ; then echo -e "\n########\n## -> Removing the Chromium Snap …\n########\n" && sudo snap remove --purge chromium ; fi

                    # Disable Snap daemon and remove snapd and remaining Snaps
                    # entirely
                    echo -e "\n########\n## -> Removing snapd …\n########\n"
                    sudo systemctl disable --now snapd.service
                    sudo pkcon remove --autoremove -y snapd && sudo apt-get remove --purge -y snapd

                    # Uninstall Snap support tools, if they are still installed
                    # e.g. due to apt-mark
                    if dpkg -l squashfs-tools 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n## -> Removing Snap support: squashfs-tools …\n########\n" && sudo apt-get purge -y squashfs-tools ; fi

                    # Uninstall Discover support for Snap, if it is still
                    # installed
                    if dpkg -l plasma-discover-backend-snap 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n## -> Removing plasma-discover-backend-snap …\n########\n" && sudo pkcon remove --autoremove -y plasma-discover-backend-snap && sudo apt-get remove --purge -y plasma-discover-backend-snap ; fi
                    if dpkg -l plasma-discover-snap-backend 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n## -> Removing plasma-discover-snap-backend …\n########\n" && sudo pkcon remove --autoremove -y plasma-discover-snap-backend && sudo apt-get remove --purge -y plasma-discover-snap-backend ; fi

                    # Uninstall Snap support libraries, if they are still
                    # installed e.g. due to apt-mark
                    if dpkg -l libsnapd-qt1 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n## -> Removing Snap support: libsnapd-qt1 …\n########\n" && sudo apt-get purge -y libsnapd-qt1 ; fi
                    if dpkg -l libsnapd-qt-2-1 2> /dev/null | grep "^ii" &> /dev/null ; then echo -e "\n########\n##  Removing Snap support: libsnapd-qt-2-1 …\n########\n" && sudo apt-get purge -y libsnapd-qt-2-1 ; fi

                    # Remove all possible and impossible Snap directories that
                    # may exist
                    echo -e "\n########\n## -> Removing Snap directories …\n########"
                    # Remove snap directory from $HOME, if it exists
                    if test -d "$HOME/snap" ; then sudo rm -rf /home/*/snap ; fi
                    # Remove snap directory from /root, if it exists
                    if sudo test -d "/root/snap" ; then sudo rm -rf /root/snap ; fi
                    # Remove snap directory from /var, if it exists
                    if test -d "/var/snap" ; then sudo rm -rf /var/snap ; fi
                    # Remove snapd directory from /var/cache, if it exists
                    if test -d "/var/cache/snapd" ; then sudo rm -rf /var/cache/snapd ; fi
                    # Additionally remove snap directory from /, if it exists
                    if test -d "/snap" ; then sudo rm -rf /snap ; fi
                    # Additionally remove snapd directory from /var/lib, if it
                    # exists
                    if test -d "/var/lib/snapd" ; then sudo rm -rf /var/lib/snapd ; fi
                    # Additionally remove snapd directory from /usr/lib, if it
                    # exists
                    if test -d "/usr/lib/snapd" ; then sudo rm -rf /usr/lib/snapd ; fi

                    # Remove broken symbolic links from
                    # /etc/systemd/system/default.target.wants, if they exist
                    for bsymlink in /etc/systemd/system/default.target.wants/snap-* ; do test -L "${bsymlink}" && sudo rm -f "${bsymlink}" && echo -e "\n########\n## -> Removing broken symbolic link :\n##    ${bsymlink} …\n########" ; done

                    # Prevent Snap from being installed again by APT pinning in
                    # /etc/apt/preferences.d like Linux Mint does
                    echo -e "\n########\n## -> Writing the following to /etc/apt/preferences.d/no_snapd.pref :\n########\n"
                    echo -e "# To prevent repository packages from triggering the installation of Snap,\n# this file forbids snapd from being installed by APT.\n\nPackage: snapd\nPin: release a=*\nPin-Priority: -10" | sudo tee /etc/apt/preferences.d/no_snapd.pref

                    # Test if the "Mozilla Team PPA" placeholder file is in
                    # $HOME AND Firefox from Mozilla.org has not been installed
                    # in the meantime, re-enable the Mozilla Team PPA if the
                    # user had this PPA enabled before running the
                    # "reinstall_Snap_for_release-upgrade" script and remove the
                    # placeholder file
                    if ! [[ -x "/opt/firefox/firefox" && $(command -v firefox) ]] && test -f "$HOME/.mtppa-placeholder" ; then echo -e "\n########\n## -> Re-enabling the Mozilla Team PPA …\n########\n" && sudo add-apt-repository -y ppa:mozillateam/ppa && rm -f "$HOME/.mtppa-placeholder" && inmtppa=1; fi

                    # Remove the placeholder file if Firefox from Mozilla.org
                    # has been installed in the meantime
                    if [[ -x "/opt/firefox/firefox" && $(command -v firefox) ]] && test -f "$HOME/.mtppa-placeholder" ; then rm -f "$HOME/.mtppa-placeholder" ; fi

                    # Test if the "prefer Firefox from the Mozilla Team PPA APT
                    # pinning" placeholder file is in $HOME and the Mozilla Team
                    # PPA is enabled AND Firefox from Mozilla.org has not been
                    # installed in the meantime, prioritise Firefox from the
                    # Mozilla Team PPA by APT pinning in /etc/apt/preferences.d
                    # again, if the user had APT pinning for Firefox from there
                    # before running the "reinstall_Snap_for_release-upgrade"
                    # script and remove the placeholder file
                    if ! [[ -x "/opt/firefox/firefox" && $(command -v firefox) ]] && test -f "$HOME/.mtppa-ffpin-placeholder" && [[ ${inmtppa} = 1 ]] ; then echo -e "\n########\n## -> Rewriting the following to /etc/apt/preferences.d/mtppa-ffpin.pref :\n########\n" && echo -e "# To prefer installing and updating Firefox from the Mozilla Team PPA to the\n# Snap version, this file prioritises those Firefox packages.\n\nPackage: firefox\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 550\n\nPackage: firefox-*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 550\n\nPackage: firefox-locale-*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 550\n" | sudo tee /etc/apt/preferences.d/mtppa-ffpin.pref && rm -f "$HOME/.mtppa-ffpin-placeholder" && sudo apt-get update && inffpin=1 ; fi

                    # Remove the placeholder file if Firefox from Mozilla.org
                    # has been installed in the meantime
                    if [[ -x "/opt/firefox/firefox" && $(command -v firefox) ]] && test -f "$HOME/.mtppa-ffpin-placeholder" ; then rm -f "$HOME/.mtppa-ffpin-placeholder" ; fi

                    # Test if the "Firefox from the Mozilla Team PPA"
                    # placeholder file is in $HOME and APT pinning for Firefox
                    # from there is applied AND Firefox from Mozilla.org has not
                    # been installed in the meantime, reinstall Firefox from the
                    # Mozilla Team PPA if the user had it installed before
                    # running the "reinstall_Snap_for_release-upgrade" script
                    # and remove the placeholder file
                    if ! [[ -x "/opt/firefox/firefox" && $(command -v firefox) ]] && test -f "$HOME/.mtff-placeholder"  && [[ ${inffpin} = 1 ]] ; then echo -e "\n########\n## -> Reinstalling Firefox from the Mozilla Team PPA …\n########\n" && sudo apt-get install -t 'o=LP-PPA-mozillateam' -y firefox && rm -f "$HOME/.mtff-placeholder" && inmtff=1; fi

                    # Remove the placeholder file if Firefox from Mozilla.org
                    # has been installed in the meantime
                    if [[ -x "/opt/firefox/firefox" && $(command -v firefox) ]] && test -f "$HOME/.mtff-placeholder" ; then rm -f "$HOME/.mtff-placeholder" ; fi

                    rmsnap=1
                    break 2
                elif [[ "${confirm}" = [Nn] ]]
                then
                    echo -e "\n########\n## You canceled the removal of Snap -> not changing anything …\n########"
                    break 2
                fi
            done
        else
            echo -e "\n########\n## Neither snapd nor Snaps seem to be installed -> not changing anything …\n########"
            break
        fi
    elif [[ "${answer}" = [Nn] ]]
    then
        echo -e "\n########\n## You canceled the removal of Snap -> not changing anything …\n########"
        break
    fi
done

########
## Report what has been done
########
summary_first="\n########\n## -> SUMMARY:"
summary_inmtppa="## The Mozilla Team PPA has been re-enabled as it was before you reinstalled\n## Snap with the \"reinstall_Snap_for_release-upgrade\" script."
summary_inmtff="## Firefox from the Mozilla Team PPA has been reinstalled as it was before you\n## reinstalled Snap with the \"reinstall_Snap_for_release-upgrade\" script."
summary_inffpin="## Firefox from the Mozilla Team PPA is prioritised by APT pinning again as it\n## was before you reinstalled Snap with the \"reinstall_Snap_for_release-upgrade\"\n## script."
summary_nochanges="## The script has made no changes at all to your system!"
summary_reboot="## -> It is strongly recommended that you reboot your computer now!"
summary_last="## Have a nice day and enjoy a snap-free Kubuntu™.\n########\n"
savesummary=0

if [[ ${rmsnap} = 1 ]] && [[ ${rmffsnap} = 1 ]]
then
    # Tell that Snap including the Firefox Snap has been removed and recommend system reboot
    echo -e "${summary_first}"
    echo -e "## Snap including the Firefox Snap has been removed from your system and the"
    echo -e "## future installation of Snap has been blocked by APT pinning in"
    echo -e "## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"."
    if [[ ${inmtppa} = 1 ]] ; then echo -e "${summary_inmtppa}" ; fi
    if [[ ${inmtff} = 1 ]] ; then echo -e "${summary_inmtff}" ; fi
    if [[ ${inffpin} = 1 ]] ; then echo -e "${summary_inffpin}" ; fi
    echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a"
    echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 22.04 LTS to"
    echo -e "##    23.04)!"
    echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script."
    echo -e "${summary_reboot}"
    echo -e "${summary_last}"
    savesummary=1
elif [[ ${rmsnap} = 1 ]] && [[ ${rmffsnap} = 0 ]]
then
    # Tell that Snap has been removed and recommend system reboot
    echo -e "${summary_first}"
    echo -e "## Snap has been removed from your system and the future installation of Snap"
    echo -e "## has been blocked by APT pinning in /etc/apt/preferences.d - the file is named"
    echo -e "## \"no_snapd.pref\"."
    if [[ ${inmtppa} = 1 ]] ; then echo -e "${summary_inmtppa}" ; fi
    if [[ ${inmtff} = 1 ]] ; then echo -e "${summary_inmtff}" ; fi
    if [[ ${inffpin} = 1 ]] ; then echo -e "${summary_inffpin}" ; fi
    echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a"
    echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 22.04 LTS to"
    echo -e "##    23.04)!"
    echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script."
    echo -e "${summary_reboot}"
    echo -e "${summary_last}"
    savesummary=1
elif ! command -v snap &> /dev/null
then
    # Tell that nothing has changed
    echo -e "${summary_first}"
    echo -e "${summary_nochanges}"
    echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a"
    echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 22.04 LTS to"
    echo -e "##    23.04)!"
    echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script."
    echo -e "${summary_last}"
else
    # Tell that nothing has changed
    echo -e "${summary_first}"
    echo -e "${summary_nochanges}"
    echo -e "## Have a nice day and enjoy Kubuntu™.\n########\n"
fi

########
## Give option to save the summary, if the script has changed anything
########
appendix="$(date +"%Y-%m-%d_%H:%M")"

if [[ ${savesummary} = 1 ]]
then
    echo -e "########\n## -> Do you want to save this summary for future reference?\n########"
    while true
    do
        read -p "[y/n] " wantsave
        if [[ "${wantsave}" = [Yy] ]] && [[ ${rmsnap} = 1 ]] && [[ ${rmffsnap} = 1 ]]
        then
            # Save to text file that Snap including the Firefox Snap has been
            # removed and system reboot is recommended
            echo -e "${summary_first}" > "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "## Snap including the Firefox Snap has been removed from your system and the" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "## future installation of Snap has been blocked by APT pinning in" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "## /etc/apt/preferences.d - the file is named \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            if [[ ${inmtppa} = 1 ]] ; then echo -e "${summary_inmtppa}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            if [[ ${inmtff} = 1 ]] ; then echo -e "${summary_inmtff}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            if [[ ${inffpin} = 1 ]] ; then echo -e "${summary_inffpin}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 22.04 LTS to" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    23.04)!" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_reboot}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_last}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "Script version used: ${versionnr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "\n########\n## -> The summary of what has been done by this script was saved to:\n##    $HOME/get_rid_of_Snap-SUMMARY_${appendix}\n########\n"
            break
        elif [[ "${wantsave}" = [Yy] ]] && [[ ${rmsnap} = 1 ]] && [[ ${rmffsnap} = 0 ]]
        then
            # Save to text file that Snap has been removed and system reboot is
            # recommended
            echo -e "${summary_first}" > "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "## Snap has been removed from your system and the future installation of Snap" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "## has been blocked by APT pinning in /etc/apt/preferences.d - the file is named" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "## \"no_snapd.pref\"." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            if [[ ${inmtppa} = 1 ]] ; then echo -e "${summary_inmtppa}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            if [[ ${inmtff} = 1 ]] ; then echo -e "${summary_inmtff}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            if [[ ${inffpin} = 1 ]] ; then echo -e "${summary_inffpin}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt" ; fi
            echo -e "## -> Be sure to remove any relevant APT pinning and reinstall Snap BEFORE a" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    release-upgrade to the next main Kubuntu™ version (e.g. from 22.04 LTS to" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    23.04)!" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "##    You can do both with the \"reinstall_Snap_for_release-upgrade\" script." >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_reboot}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "${summary_last}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "Script version used: ${versionnr}" >> "$HOME/get_rid_of_Snap-SUMMARY_${appendix}.txt"
            echo -e "\n########\n## -> The summary of what has been done by this script was saved to:\n##    $HOME/get_rid_of_Snap-SUMMARY_${appendix}\n########\n"
            break
        elif [[ "${wantsave}" = [Nn] ]]
        then
            echo
            break
        fi
    done
fi

########
## Give option to reboot, if this has been recommended
########
if [[ ${rmsnap} = 1 ]]
then
    echo -e "########\n## -> Do you want to reboot your system now as recommended?\n########"
    while true
    do
        read -p "[y/n] " rebootpc
        if [[ "${rebootpc}" = [Yy] ]]
        then
            reboot
            break
        elif [[ "${rebootpc}" = [Nn] ]]
        then
            echo
            break
        fi
    done
fi
