#!/bin/bash

set -e

function main() {
  MSR_SCRIPT_DIRECTORY="$(cd "$(dirname $BASH_SOURCE)" && pwd)"
  source "$MSR_SCRIPT_DIRECTORY/lib/variables.sh"
  source "$MSR_SCRIPT_DIRECTORY/lib/functions.sh"

  if ! isRoot; then
    printMessage "[ERR] Please run this script as 'root' user!" $MSR_COLOR_ERROR 0 0
    exit
  fi

  printMessage "*** Docker Setup ***" $MSR_COLOR_TITLE 1 0

  printMessage "(1) Update packages:" $MSR_COLOR_TASK 1 0
  runAptitude
  printMessage "[OK] All packages have been checked!" $MSR_COLOR_SUCCESS 0 0

  printMessage "(2) Pull Docker repository:" $MSR_COLOR_TASK 1 0
  installPackages "apt-transport-https ca-certificates curl gnupg-agent software-properties-common"
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
  printMessage "[OK] Docker repository has been pulled!" $MSR_COLOR_SUCCESS 0 0

  printMessage "(3) Add Docker repository:" $MSR_COLOR_TASK 1 0
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  printMessage "[OK] Docker repository has been added!" $MSR_COLOR_SUCCESS 0 0

  printMessage "(4) Install Docker:" $MSR_COLOR_TASK 1 0
  runAptitude
  installPackages "docker-ce docker-ce-cli containerd.io"
  printMessage "[OK] Docker has been installed!" $MSR_COLOR_SUCCESS 0 0

  printMessage "\xE2\x9C\x94 Setup is completed!" $MSR_COLOR_COMPLETE 1 0
}

main
