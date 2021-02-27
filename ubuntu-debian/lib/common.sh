MSR_COLOR_TITLE="1;95"
MSR_COLOR_TASK="94"
MSR_COLOR_ERROR="91"
MSR_COLOR_SUCCESS="92"
MSR_COLOR_COMPLETE="1;96"

function printMessage() {
  local message=$1
  local color=$2
  local start=$3
  local end=$4

  if [ $start != 0 ]; then
    local start="\n"
  else
    local start=""
  fi

  if [ $end != 0 ]; then
    local end="\n"
  else
    local end=""
  fi

  echo -e $start"\e["$color"m"$message"\e[0m"$end
}

function isRoot() {
  [[ $(id -u) == 0 ]]
}

function runAptitude() {
  apt update
  apt upgrade
  apt autoremove
  apt clean
}

function isInstalled() {
  local package=$1

  dpkg -s "$package" &>/dev/null

  [[ $? == 0 ]]
}

function installPackage() {
  local package=$1

  apt install $package -y
}
