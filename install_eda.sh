#!/bin/bash
set -e

########################################
# Configuration
########################################
EDA_DIR="$HOME/eda_tools"
SWAPFILE="/swapfile"
THREADS=1   # safe for RAM
SOFTWARE="all"       # default: install both
OPENROAD_MODE="light"  # default OpenROAD build

########################################
# Argument parsing
# Usage: ./install_eda.sh [openroad|opensta|all] [light|complete]
########################################
if [[ "$1" == "openroad" || "$1" == "opensta" || "$1" == "all" ]]; then
  SOFTWARE="$1"
elif [[ -n "$1" ]]; then
  echo "Usage: $0 [openroad|opensta|all] [light|complete]"
  exit 1
fi

if [[ "$2" == "light" || "$2" == "complete" ]]; then
  OPENROAD_MODE="$2"
elif [[ -n "$2" ]]; then
  echo "Usage: $0 [openroad|opensta|all] [light|complete]"
  exit 1
fi

########################################
# Reset workspace
########################################
rm -rf "$EDA_DIR/OpenROAD" "$EDA_DIR/OpenSTA"
mkdir -p "$EDA_DIR"
cd "$EDA_DIR"

########################################
# System dependencies
########################################
sudo apt update
sudo apt install -y \
  build-essential git cmake \
  tcl-dev tk-dev \
  bison flex \
  libboost-all-dev \
  libpcre2-dev

########################################
# Swap handling
########################################
if ! swapon --show | grep -q "$SWAPFILE"; then
  sudo fallocate -l 12G "$SWAPFILE"
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE"
  sudo swapon "$SWAPFILE"
fi

########################################
# OpenROAD installation
########################################
if [[ "$SOFTWARE" == "openroad" || "$SOFTWARE" == "all" ]]; then
  git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git
  cd OpenROAD
  sudo ./etc/DependencyInstaller.sh -base
  mkdir build
  cd build

  if [[ "$OPENROAD_MODE" == "light" ]]; then
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=20 \
      -DCMAKE_CXX_STANDARD_REQUIRED=ON \
      -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
      -DBUILD_GUI=OFF \
      -DBUILD_PYTHON=OFF \
      -DBUILD_MPL=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_PAR=OFF \
      -DBUILD_ABC=OFF \
      -DBUILD_RSZ=ON \
      -DBUILD_GRT=ON \
      -DBUILD_CTS=ON \
      -DBUILD_DB=ON \
      -DBUILD_ODB=ON \
      -DBUILD_STA=ON
  else
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=20 \
      -DCMAKE_CXX_STANDARD_REQUIRED=ON \
      -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
      -DBUILD_GUI=ON \
      -DBUILD_PYTHON=ON \
      -DBUILD_MPL=ON \
      -DBUILD_TESTS=OFF
  fi

  make -j$THREADS
  cd "$EDA_DIR"
fi

########################################
# OpenSTA installation
########################################
if [[ "$SOFTWARE" == "opensta" || "$SOFTWARE" == "all" ]]; then
  git clone https://github.com/The-OpenROAD-Project/OpenSTA.git
  cd OpenSTA
  mkdir build && cd build
  cmake .. -DCMAKE_BUILD_TYPE=Release
  make -j$THREADS
  cd "$EDA_DIR"
fi

########################################
# PATH registration
########################################
EXPORT_LINE="export PATH=\$PATH:$EDA_DIR/OpenROAD/build/src:$EDA_DIR/OpenSTA/build"
grep -qxF "$EXPORT_LINE" ~/.bashrc || echo "$EXPORT_LINE" >> ~/.bashrc
export PATH="$PATH:$EDA_DIR/OpenROAD/build/src:$EDA_DIR/OpenSTA/build"

########################################
# Sanity check
########################################
if [[ -x "$EDA_DIR/OpenROAD/build/src/openroad" ]]; then
  openroad -version
fi
if [[ -x "$EDA_DIR/OpenSTA/build/sta" ]]; then
  sta -help
fi
