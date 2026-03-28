#!/usr/bin/env bash
set -euo pipefail

# XMRig Termux Installer / Miner Launcher
# Author: AGX Academy
# GitHub: https://github.com/AGX-Academy

POOL="gulf.moneroocean.stream:10128"
REPO_URL="https://github.com/xmrig/xmrig.git"
INSTALL_DIR="$HOME/xmrig"
BUILD_DIR="$INSTALL_DIR/build"

function echo_header() {
  echo
  echo "==============================================="
  echo "   Ready to build your mining future today"
  echo "==============================================="
  echo "   XMRig Termux Installer and Miner Launcher"
  echo "==============================================="
  echo "   Author: AGX Academy"
  echo "   GitHub: https://github.com/AGX-Academy"
  echo "   WhatsApp: https://wa.me/+994402309201"
  echo "   Telegram: https://t.me/Developer_GX"
  echo "==============================================="
  echo "   Keep calm, stay focused, and let your rig run."
  echo
}

function show_animation() {
  local spin='|/-\\'
  local messages=(
    "Preparing your mining rig..."
    "Fueling the crypto engine..."
    "Connecting to gulf.moneroocean.stream..."
    "Almost there, champion..."
  )

  for msg in "${messages[@]}"; do
    for i in {0..7}; do
      printf '\r[ %c ] %s' "${spin:i%4:1}" "$msg"
      sleep 0.14
    done
    printf '\r[ ✓ ] %s\n' "$msg"
  done
  echo
}

function die() {
  echo "Error: $1" >&2
  exit 1
}

function check_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command '$1' is not installed."
}

function prompt_wallet() {
  read -rp "Enter your Monero wallet address: " WALLET
  if [[ -z "${WALLET// /}" ]]; then
    die "Wallet address cannot be empty."
  fi
  echo "$WALLET"
}

function prompt_password() {
  read -rp "Enter mining password / worker name (default: x): " PASSWORD
  if [[ -z "${PASSWORD// /}" ]]; then
    PASSWORD="x"
  fi
  echo "$PASSWORD"
}

function install_dependencies() {
  echo "Updating Termux packages..."
  apt update -y
  apt upgrade -y
  echo "Installing git, build-essential, and cmake..."
  apt install git build-essential cmake -y
}

function clone_or_update_repo() {
  if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "Updating existing xmrig repository..."
    cd "$INSTALL_DIR"
    git pull --rebase
  else
    echo "Cloning xmrig repository to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
  fi
}

function build_xmrig() {
  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  echo "Configuring build..."
  cmake .. -DWITH_HWLOC=OFF
  echo "Building xmrig (parallel jobs: $(nproc))..."
  make -j"$(nproc)"
}

function launch_miner() {
  local wallet="$1"
  local password="$2"
  cd "$BUILD_DIR"
  echo "Starting miner using pool: $POOL"
  echo "Wallet: $wallet"
  echo "Password: $password"
  printf '\n' "Miner is running. Press Ctrl+C to stop."
  ./xmrig -o "$POOL" -a randomx -u "$wallet" -p "$password"
}

# Main
clear
echo_header
show_animation
install_dependencies
clone_or_update_repo
build_xmrig

WALLET="$(prompt_wallet)"
PASSWORD="$(prompt_password)"

launch_miner "$WALLET" "$PASSWORD"
