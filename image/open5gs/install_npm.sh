#!/bin/bash

# Refer to Node.js install script
#
# Run as root or insert `sudo -E` before `bash`:
#
# curl -fsSL https://open5gs.org/open5gs/assets/webui/install | sudo -E bash -
#   or
# wget -qO- https://open5gs.org/open5gs/assets/webui/install | sudo -E bash -
#

PACKAGE="open5gs"
VERSION="2.6.1"

print_status() {
    echo
    echo "## $1"
    echo
}

if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

print_bold() {
    title="$1"
    text="$2"

    echo
    echo "${red}================================================================================${normal}"
    echo "${red}================================================================================${normal}"
    echo
    echo -e "  ${bold}${yellow}${title}${normal}"
    echo
    echo -en "  ${text}"
    echo
    echo "${red}================================================================================${normal}"
    echo "${red}================================================================================${normal}"
}

bail() {
    echo 'Error executing command, exiting'
    exit 1
}

exec_cmd_nobail() {
    echo "+ $1"
    bash -c "$1"
}

exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

uninstall() {
if [ -f /lib/systemd/system/${PACKAGE}-webui.service ]; then
    STATUS="$(systemctl is-active open5gs-webui.service)"
    if [ "${STATUS}" = "active" ]; then
        exec_cmd_nobail "deb-systemd-invoke stop open5gs-webui"
    fi

    STATUS="$(systemctl is-enabled open5gs-webui.service)"
    if [ "${STATUS}" = "enabled" ]; then
        exec_cmd_nobail "systemctl disable open5gs-webui"
    fi

    exec_cmd_nobail "rm -f /lib/systemd/system/${PACKAGE}-webui.service"
    exec_cmd_nobail "systemctl daemon-reload"
fi

if [ -d /usr/lib/node_modules/${PACKAGE} ]; then
    exec_cmd_nobail "rm -rf /usr/lib/node_modules/${PACKAGE}"
fi

}

preinstall() {

if [ ! -x /usr/bin/mongod ]; then
    print_status "First you need to install MongoDB packages."
    exit 1
fi

if [ ! -x /usr/bin/npm ]; then
    print_status "First you need to install NPM packages."
    exit 1
fi

PRE_INSTALL_PKGS=""

# Check that HTTPS transport is available to APT
# (Check snaked from: https://get.docker.io/ubuntu/)

if [ ! -e /usr/lib/apt/methods/https ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} apt-transport-https"
fi

if [ ! -x /usr/bin/lsb_release ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} lsb-release"
fi

if [ ! -x /usr/bin/curl ] && [ ! -x /usr/bin/wget ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} curl"
fi

# Used by apt-key to add new keys

if [ ! -x /usr/bin/gpg ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} gnupg"
fi

print_status "Populating apt-get cache..."
exec_cmd 'apt-get update'

if [ "X${PRE_INSTALL_PKGS}" != "X" ]; then
    print_status "Installing packages required for setup:${PRE_INSTALL_PKGS}..."
    # This next command needs to be redirected to /dev/null or the script will bork
    # in some environments
    exec_cmd "apt-get install -y${PRE_INSTALL_PKGS} > /dev/null 2>&1"
fi

IS_PRERELEASE=$(lsb_release -d | grep 'Ubuntu .*development' >& /dev/null; echo $?)
if [[ $IS_PRERELEASE -eq 0 ]]; then
    print_status "Your distribution, identified as \"$(lsb_release -d -s)\", is a pre-release version of Ubuntu. NodeSource does not maintain official support for Ubuntu versions until they are formally released. You can try using the manual installation instructions available at https://github.com/nodesource/distributions and use the latest supported Ubuntu version name as the distribution identifier, although this is not guaranteed to work."
    exit 1
fi

DISTRO=$(lsb_release -c -s)

check_alt() {
    if [ "X${DISTRO}" == "X${2}" ]; then
        echo
        echo "## You seem to be using ${1} version ${DISTRO}."
        echo "## This maps to ${3} \"${4}\"... Adjusting for you..."
        DISTRO="${4}"
    fi
}

check_alt "Astra Linux"    "orel"            "Debian"        "stretch"
check_alt "BOSS"           "anokha"          "Debian"        "wheezy"
check_alt "BOSS"           "anoop"           "Debian"        "jessie"
check_alt "BOSS"           "drishti"         "Debian"        "stretch"
check_alt "BOSS"           "unnati"          "Debian"        "buster"
check_alt "BOSS"           "urja"            "Debian"        "bullseye"
check_alt "bunsenlabs"     "bunsen-hydrogen" "Debian"        "jessie"
check_alt "bunsenlabs"     "helium"          "Debian"        "stretch"
check_alt "bunsenlabs"     "lithium"         "Debian"        "buster"
check_alt "Devuan"         "jessie"          "Debian"        "jessie"
check_alt "Devuan"         "ascii"           "Debian"        "stretch"
check_alt "Devuan"         "beowulf"         "Debian"        "buster"
check_alt "Devuan"         "chimaera"        "Debian"        "bullseye"
check_alt "Devuan"         "ceres"           "Debian"        "sid"
check_alt "Deepin"         "panda"           "Debian"        "sid"
check_alt "Deepin"         "unstable"        "Debian"        "sid"
check_alt "Deepin"         "stable"          "Debian"        "buster"
check_alt "Deepin"         "apricot"         "Debian"        "buster"
check_alt "elementaryOS"   "luna"            "Ubuntu"        "precise"
check_alt "elementaryOS"   "freya"           "Ubuntu"        "trusty"
check_alt "elementaryOS"   "loki"            "Ubuntu"        "xenial"
check_alt "elementaryOS"   "juno"            "Ubuntu"        "bionic"
check_alt "elementaryOS"   "hera"            "Ubuntu"        "bionic"
check_alt "elementaryOS"   "odin"            "Ubuntu"        "focal"
check_alt "elementaryOS"   "jolnir"          "Ubuntu"        "focal"
check_alt "Kali"           "sana"            "Debian"        "jessie"
check_alt "Kali"           "kali-rolling"    "Debian"        "bullseye"
check_alt "Linux Mint"     "maya"            "Ubuntu"        "precise"
check_alt "Linux Mint"     "qiana"           "Ubuntu"        "trusty"
check_alt "Linux Mint"     "rafaela"         "Ubuntu"        "trusty"
check_alt "Linux Mint"     "rebecca"         "Ubuntu"        "trusty"
check_alt "Linux Mint"     "rosa"            "Ubuntu"        "trusty"
check_alt "Linux Mint"     "sarah"           "Ubuntu"        "xenial"
check_alt "Linux Mint"     "serena"          "Ubuntu"        "xenial"
check_alt "Linux Mint"     "sonya"           "Ubuntu"        "xenial"
check_alt "Linux Mint"     "sylvia"          "Ubuntu"        "xenial"
check_alt "Linux Mint"     "tara"            "Ubuntu"        "bionic"
check_alt "Linux Mint"     "tessa"           "Ubuntu"        "bionic"
check_alt "Linux Mint"     "tina"            "Ubuntu"        "bionic"
check_alt "Linux Mint"     "tricia"          "Ubuntu"        "bionic"
check_alt "Linux Mint"     "ulyana"          "Ubuntu"        "focal"
check_alt "Linux Mint"     "ulyssa"          "Ubuntu"        "focal"
check_alt "Linux Mint"     "uma"             "Ubuntu"        "focal"
check_alt "Linux Mint"     "una"             "Ubuntu"        "focal"
check_alt "Linux Mint"     "vanessa"         "Ubuntu"        "jammy"
check_alt "Liquid Lemur"   "lemur-3"         "Debian"        "stretch"
check_alt "LMDE"           "betsy"           "Debian"        "jessie"
check_alt "LMDE"           "cindy"           "Debian"        "stretch"
check_alt "LMDE"           "debbie"          "Debian"        "buster"
check_alt "LMDE"           "elsie"           "Debian"        "bullseye"
check_alt "MX Linux 17"    "Horizon"         "Debian"        "stretch"
check_alt "MX Linux 18"    "Continuum"       "Debian"        "stretch"
check_alt "MX Linux 19"    "patito feo"      "Debian"        "buster"
check_alt "MX Linux 21"    "wildflower"      "Debian"        "bullseye"
check_alt "Pardus"         "onyedi"          "Debian"        "stretch"
check_alt "Parrot"         "ara"             "Debian"        "bullseye"
check_alt "PureOS"         "green"           "Debian"        "sid"
check_alt "PureOS"         "amber"           "Debian"        "buster"
check_alt "PureOS"         "byzantium"       "Debian"        "bullseye"
check_alt "SolydXK"        "solydxk-9"       "Debian"        "stretch"
check_alt "Sparky Linux"   "Tyche"           "Debian"        "stretch"
check_alt "Sparky Linux"   "Nibiru"          "Debian"        "buster"
check_alt "Sparky Linux"   "Po-Tolo"         "Debian"        "bullseye"
check_alt "Tanglu"         "chromodoris"     "Debian"        "jessie"
check_alt "Trisquel"       "toutatis"        "Ubuntu"        "precise"
check_alt "Trisquel"       "belenos"         "Ubuntu"        "trusty"
check_alt "Trisquel"       "flidas"          "Ubuntu"        "xenial"
check_alt "Trisquel"       "etiona"          "Ubuntu"        "bionic"
check_alt "Ubilinux"       "dolcetto"        "Debian"        "stretch"
check_alt "Uruk GNU/Linux" "lugalbanda"      "Ubuntu"        "xenial"

if [ "X${DISTRO}" == "Xdebian" ]; then
  print_status "Unknown Debian-based distribution, checking /etc/debian_version..."
  NEWDISTRO=$([ -e /etc/debian_version ] && cut -d/ -f1 < /etc/debian_version)
  if [ "X${NEWDISTRO}" == "X" ]; then
    print_status "Could not determine distribution from /etc/debian_version..."
  else
    DISTRO=$NEWDISTRO
    print_status "Found \"${DISTRO}\" in /etc/debian_version..."
  fi
fi
}

install() {
print_status "Download the Open5GS Source Code (v${VERSION})..."
if [ -x /usr/bin/curl ]; then
    exec_cmd "curl -sLf 'https://github.com/open5gs/${PACKAGE}/archive/v${VERSION}.tar.gz' | tar zxf -"
    RC=$?
else
    exec_cmd "wget -qO - 'https://github.com/open5gs/${PACKAGE}/archive/v${VERSION}.tar.gz' | tar zxf -"
    RC=$?
fi

if [[ $RC != 0 ]]; then
    print_status "Failed to download: https://github.com/open5gs/${PACKAGE}/archive/v${VERSION}.tar.gz"
    exit 1
fi

print_status "Build the Open5GS WebUI..."
exec_cmd "cd ./${PACKAGE}-${VERSION}/webui && npm clean-install && npm run build"

print_status "Install the Open5GS WebUI..."
exec_cmd "mv ./${PACKAGE}-${VERSION}/webui /usr/lib/node_modules/${PACKAGE}"
exec_cmd_nobail "chown -R open5gs:open5gs /usr/lib/node_modules/${PACKAGE}"

}

postinstall() {

print_status "Default Administrator Account [Username:admin, Password:1423]..."
if [ -x /usr/bin/mongo ];
then
    exec_cmd "mongo open5gs ./${PACKAGE}-${VERSION}/docs/assets/webui/mongo-init.js"
elif [ -x /usr/bin/mongosh ];
then
    exec_cmd "mongosh open5gs ./${PACKAGE}-${VERSION}/docs/assets/webui/mongo-init.js"
else
    echo "Failed to execute mongo-init.js"
fi

exec_cmd "rm -rf ./${PACKAGE}-${VERSION}"
}

## Defer setup until we have the complete script
uninstall
preinstall
install
# postinstall
