#!/bin/bash
#
# Rails Ready
#
# Author: Josh Frye <joshfng@gmail.com>
# Licence: MIT
#
# Contributions from: Wayne E. Seguin <wayneeseguin@gmail.com>
# Contributions from: Ryan McGeary <ryan@mcgeary.org>
#

ruby_version=$1
ruby_version_string=$2
ruby_source_url=$3
ruby_source_tar_name=$4
ruby_source_dir_name=$5
script_runner=$(whoami)
railsready_path=$7
log_file=$8

#echo "vars set: $ruby_version $ruby_version_string $ruby_source_url $ruby_source_tar_name $ruby_source_dir_name $whichRuby $railsinstall_path $log_file"

echo -e "\nInstalling Homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.github.com/gist/1209017)" >> $log_file 2>&1
echo "==> done..."

# Install git-core
echo -e "\n=> Updating git..."
brew install git >> $log_file 2>&1
echo "==> done..."