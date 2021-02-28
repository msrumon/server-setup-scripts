#!/bin/bash

set -e

function prompt4username() {
  local username

  read -rp "> Enter a new username: " username

  if [[ -z $username ]]; then
    printMessage "[ERR] Username cannot be empty!" $MSR_COLOR_ERROR 0 1 1>&2
    prompt4username
  else
    echo $username
  fi
}

function prompt4password() {
  local username=$1
  local password

  read -srp "> Enter password for '$username' user: " password

  if [[ -z $password ]]; then
    printMessage "[ERR] Password cannot be empty!" $MSR_COLOR_ERROR 1 1 1>&2
    prompt4password $username
  else
    echo $password
  fi
}

function addUser() {
  local username=$1
  local password=$2

  adduser --disabled-password --gecos "" "$username"
  echo "$username:$password" | chpasswd
}

function grantPrivilege() {
  local username=$1

  usermod -aG sudo "$username"
}

function installRequiredPackage() {
  local required=$1

  if ! isInstalled $required; then
    installPackages $required
  fi
}

function disableRootLogin() {
  installRequiredPackage "openssh-server"

  sed -re "s/^\#?(PasswordAuthentication)([[:space:]]+)yes/\1\2no/" -i /etc/ssh/sshd_config
  sed -re "s/^\#?(PermitRootLogin)([[:space:]]+)(.*)/PermitRootLogin no/" -i /etc/ssh/sshd_config
}

function setupBasicFirewall() {
  installRequiredPackage "ufw"

  ufw allow OpenSSH
  ufw --force enable
}

function main() {
  MSR_SCRIPT_DIRECTORY="$(cd "$(dirname $BASH_SOURCE)" && pwd)"
  source "$MSR_SCRIPT_DIRECTORY/lib/variables.sh"
  source "$MSR_SCRIPT_DIRECTORY/lib/functions.sh"

  if ! isRoot; then
    printMessage "[ERR] Please run this script as 'root' user!" $MSR_COLOR_ERROR 0 0
    exit
  fi

  printMessage "*** Initial Server Setup ***" $MSR_COLOR_TITLE 1 0

  printMessage "(1) Update packages:" $MSR_COLOR_TASK 1 0
  runAptitude
  printMessage "[OK] All packages have been checked!" $MSR_COLOR_SUCCESS 0 0

  printMessage "(2) Add new user:" $MSR_COLOR_TASK 1 0
  MSR_USERNAME=$(prompt4username)
  MSR_PASSWORD=$(prompt4password $MSR_USERNAME)
  addUser $MSR_USERNAME $MSR_PASSWORD
  grantPrivilege $MSR_USERNAME
  printMessage "[OK] A user '$MSR_USERNAME' has been configured!" $MSR_COLOR_SUCCESS 0 0

  printMessage "(3) Disable 'root' login through SSH:" $MSR_COLOR_TASK 1 0
  disableRootLogin
  printMessage "[OK] Logging in as 'root' has been disabled!" $MSR_COLOR_SUCCESS 0 0

  printMessage "(4) Setup firewall:" $MSR_COLOR_TASK 1 0
  setupBasicFirewall
  printMessage "[OK] 'UFW' firewall has been setup!" $MSR_COLOR_SUCCESS 0 0

  service sshd restart
  printMessage "\xE2\x9C\x94 Setup is completed!" $MSR_COLOR_COMPLETE 1 0
}

main
