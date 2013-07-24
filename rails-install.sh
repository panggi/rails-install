#!/bin/bash
# Modified from Rails Ready by Josh Frye
shopt -s nocaseglob
set -e

ruby_version="2.0.0"
ruby_version_string="2.0.0-p0"
rails_version_string="4.0.0"
ruby_source_url="http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p0.tar.gz"
ruby_source_tar_name="ruby-2.0.0-p0.tar.gz"
ruby_source_dir_name="ruby-2.0.0-p0"
script_runner=$(whoami)
railsinstall_path=$(cd && pwd)/installer/rails-install
log_file="$railsinstall_path/install.log"

control_c()
{
  echo -en "\n\n*** Exiting ***\n\n"
  exit 1
}

# trap keyboard interrupt (control-c)
trap control_c SIGINT

clear

echo "#################################"
echo "########## Rails Install #########"
echo "#################################"

#determine the distro
if [[ $MACHTYPE = *linux* ]] ; then
  distro_sig=$(cat /etc/issue)
  if [[ $distro_sig =~ ubuntu ]] ; then
    distro="ubuntu"
  elif [[ $distro_sig =~ centos ]] ; then
    distro="centos"
  fi
elif [[ $MACHTYPE = *darwin* ]] ; then
  distro="osx"
    if [[ ! -f $(which gcc) ]]; then
      echo -e "\nXCode/GCC must be installed in order to build required software. Note that XCode does not automatically do this, but you may have to go to the Preferences menu and install command line tools manually.\n"
      exit 1
    fi
else
  echo -e "\nonly supports Ubuntu, CentOS and OSX\n"
  exit 1
fi

#now check if user is root
if [ $script_runner == "root" ] ; then
  echo -e "\nThis script must be run as a normal user with sudo privileges\n"
  exit 1
fi

echo -e "\n\n"
echo "run tail -f $log_file in a new terminal to watch the install"

echo -e "\n"
echo "What this script gets you:"
echo " * Ruby $ruby_version_string"
echo " * libs needed to run Rails (sqlite, mysql, etc)"
echo " * Bundler, Passenger, and Rails gems"
echo " * Git"

# Check if the user has sudo privileges.
sudo -v >/dev/null 2>&1 || { echo $script_runner has no sudo privileges ; exit 1; }

echo -e "\n\n!!! Set to install rbenv for user: $script_runner !!! \n"

echo -e "\n=> Creating install dir..."
cd && mkdir -p rails-install/src && cd rails-install && touch install.log
echo "==> done..."

echo -e "\n=> Downloading and running recipe for $distro...\n"
#Download the distro specific recipe and run it, passing along all the variables as args
if [[ $MACHTYPE = *linux* ]] ; then
  wget --no-check-certificate -O $railsinstall_path/src/$distro.sh https://raw.github.com/panggi/rails-install/master/recipes/$distro.sh && cd $railsinstall_path/src && bash $distro.sh $ruby_version $ruby_version_string $ruby_source_url $ruby_source_tar_name $ruby_source_dir_name $railsinstall_path $log_file
else
  cd $railsinstall_path/src && curl -O https://raw.github.com/panggi/rails-install/master/recipes/$distro.sh && bash $distro.sh $ruby_version $ruby_version_string $ruby_source_url $ruby_source_tar_name $ruby_source_dir_name $railsinstall_path $log_file
fi
echo -e "\n==> done running $distro specific commands..."

#now that all the distro specific packages are installed lets get Ruby

echo -e "\n=> Installing rbenv https://github.com/sstephenson/rbenv \n"
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
echo -e "\n=> Installing ruby-build  \n"
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

source ~/.bashrc
source ~/.bash_profile

echo -e "\n=> Installing ruby $ruby_version_string... \n"
rbenv install $ruby_version_string >> $log_file 2>&1
rbenv rehash
rbenv global $ruby_version_string
echo "===> done..."

echo -e "\n=> Updating Rubygems..."

gem update --system --no-ri --no-rdoc >> $log_file 2>&1

echo "==> done..."

echo -e "\n=> Installing Bundler, Passenger and Rails..."

gem install bundler passenger --no-ri --no-rdoc -f >> $log_file 2>&1
gem install rails -v $rails_version_string --no-ri --no-rdoc -f >> $log_file 2>&1

rbenv rehash

echo "==> done..."

echo -e "\n#################################"
echo    "### Installation is complete! ###"
echo -e "#################################\n"