#!/bin/sh
. $OH_MY_NEOVIM/tools/custom.sh

read -r -p "${GREEN}Would you like to install dependencies for selected plugins? [y/N]${NORMAL} " confirmation
if [ "$confirmation" = y ] || [ "$confirmation" = Y ]; then
  # runs on macos
  if [ "$(uname)" = Darwin ]; then
    plugins=$(echo $OH_MY_NEOVIM_PLUGINS | tr ' ' "\n")
    hash brew >/dev/null 2>&1 || {
      echo "Error: brew is not installed"
      echo "Please visit http://brew.sh/ and install homebrew"
      exit 0
    }
    for plugin in $plugins; do
      if [ -f $OH_MY_NEOVIM/templates/$plugin/brew ]; then
        brew_packages=$(cat $OH_MY_NEOVIM/templates/$plugin/brew)
        printf "${BLUE}Install $brew_packages with brew for $plugin ...${NORMAL}\n"
        brew install $brew_packages || {
          printf "Error [brew]: Installation for plugin \"$plugin\" failed\n"
        }
      fi
    done
  fi
  # runs on linux
  if [ "$(uname)" = Linux ]; then
    plugins=$(echo "$OH_MY_NEOVIM_PLUGINS" | grep -o -e "[^ ]*")
    # debian based system
    if [ -f /etc/debian_version ]; then
      if [ -f $OH_MY_NEOVIM/templates/$plugin/apt ]; then
        apt_packages=$(cat $OH_MY_NEOVIM/templates/$plugin/apt)
        printf "${BLUE}Install $apt_packages with apt for $plugin ...${NORMAL}\n"
        printf "${RED}sudo permissions required${NORMAL}\n"
        sudo apt-get install -y -q $apt_packages || {
          printf "Error [apt]: Installation for plugin \"$plugin\" failed\n"
        }
      fi
    elif [ -f /etc/redhat-release ]; then
      if [ -f $OH_MY_NEOVIM/templates/$plugin/yum ]; then
        yum_packages=$(cat $OH_MY_NEOVIM/templates/$plugin/yum)
        printf "${BLUE}Install $yum_packages with apt for $plugin ...${NORMAL}\n"
        printf "${RED}sudo permissions required${NORMAL}\n"
        sudo yum -y install $yum_packages || {
          printf "Error [yum]: Installation for plugin \"$plugin\" failed\n"
        }
      fi
    fi
  fi
  for plugin in $plugins; do
    # custom shell scripts
    if [ -f $OH_MY_NEOVIM/templates/$plugin/install.sh ]; then
      printf "${BLUE}Install dependencies for $plugin ...${NORMAL}\n"
      env OH_MY_NEOVIM="$OH_MY_NEOVIM" OH_MY_NEOVIM_PLUGINS="$OH_MY_NEOVIM_PLUGINS" sh "$OH_MY_NEOVIM/templates/$plugin/install.sh" || {
        printf "Error: Install dependencies for plugin \"$plugin\" failed\n"
      }
    fi
    # pip2
    if [ -f $OH_MY_NEOVIM/templates/$plugin/pip2 ]; then
      pip2_packages=$(cat $OH_MY_NEOVIM/templates/$plugin/pip2)
      printf "${BLUE}Install $pip2_packages for $plugin ...${NORMAL}\n"
      pip2 install --quiet --user --upgrade $pip2_packages || {
        printf "Error [pip2]: Install dependencies for plugin \"$plugin\" failed\n"
      }
    fi
    # pip3
    if [ -f $OH_MY_NEOVIM/templates/$plugin/pip3 ]; then
      pip3_packages=$(cat $OH_MY_NEOVIM/templates/$plugin/pip3)
      printf "${BLUE}Install $pip3_packages for $plugin ...${NORMAL}\n"
      pip3 install --quiet --user --upgrade $pip3_packages || {
        printf "Error [pip3]: Install dependencies for plugin \"$plugin\" failed\n"
      }
    fi
    # gem
    if [ -f $OH_MY_NEOVIM/templates/$plugin/gem ]; then
      gem_packages=$(cat $OH_MY_NEOVIM/templates/$plugin/gem)
      printf "${BLUE}Install $gem_packages for $plugin ...${NORMAL}\n"
      gem install --user-install $gem_packages || {
        printf "Error [gem]: Install dependencies for plugin \"$plugin\" failed\n"
      }
    fi
    # npm
    if [ -f $OH_MY_NEOVIM/templates/$plugin/npm ]; then
      npm_packages=$(cat $OH_MY_NEOVIM/templates/$plugin/npm)
      if [ ! -n "$NPM_GLOBAL_FOLDER" ]; then
        NPM_GLOBAL_FOLDER="$HOME/.node_modules_global"
      fi
      mkdir -p $NPM_GLOBAL_FOLDER
      add_to_shell_profile_if_pattern_not_found "PATH=\"$NPM_GLOBAL_FOLDER/bin:\$PATH\"" "PATH=\"$NPM_GLOBAL_FOLDER/bin:\$PATH\""
      if hash yarn 2>/dev/null; then
        node_package_manager_command="yarn global add --global-folder $NPM_GLOBAL_FOLDER"
        yarn config set prefix $NPM_GLOBAL_FOLDER
      elif hash npm 2>/dev/null; then
        node_package_manager_command="npm install --global"
        npm config set prefix $NPM_GLOBAL_FOLDER
      else
        echo "Error: npm or yarn is not installed"
        echo "Please visit https://yarnpkg.com/ or https://nodejs.org/ and install node package manager"
        exit 0
      fi
      printf "${BLUE}Install $npm_packages with node package manager for $plugin ...${NORMAL}\n"
      sh -c "$node_package_manager_command $npm_packages" || {
        printf "Error [npm]: Installation for plugin \"$plugin\" failed\n"
      }
    fi
  done
  printf "\n${GREEN}Oh my Neovim plugin dependencies are now installed!${NORMAL}\n"
else
  exit 0
fi

