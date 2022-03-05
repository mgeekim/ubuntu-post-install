#!/bin/bash

set -e

sudo apt install git
git clone https://github.com/mg0721/ubuntu-post-install.git
bash ubuntu-post-install/install.sh