#!/bin/sh
# Symlink dotfiles and install necessary packages

dotfilesDir="$(cd "$(dirname "$0")" && pwd)"
homeDir="$HOME"
username="$(id -un)"

source "$dotfilesDir/bin/lib"

cprint -p "Installing Dotfiles"

os=$(detect_os)
cprint "System is: \"$os\""

cprint -p "Would you like to continue? [y/n]"
read -r response
if [ "$response" != "y" ]; then
  exit 0
fi

# PACKAGES / SYSTEM ############################################################
################################################################################
# installing required packages
if [[ "$os" == "arch" ]]; then
  cprint -p "Install Required Packages"
  sudo pacman -Syu neovim gcc make nodejs yarn xclip tmux zsh

  cprint -p "Installing pyenv"
  bash <(curl -fsSL https://pyenv.run)

  cprint -p "Change shell to zsh"
  chsh -s $(which zsh)

elif [[ "$os" == "nix" ]]; then
  cprint -p "Select your desired host to install:"
  cprint    "1. NixHyper"
  cprint    "2. NixDarwin"
  cprint    "0. Cancel"
  read -r response

  if [ "$response" == "1" ]; then
    cprint -p "Installing NixHyper"

    # rename .git since nixos doesnt deal well with repos
    sudo mv ${dotfilesDir}/.git ${dotfilesDir}/.git.bak

    # copy over config files
    sudo ln -s ${dotfilesDir}/nix/nixhyper /etc/nixos/SysSync
    sudo chmod ${username}:users /etc/nixos/*
    sudo cp /etc/nixos/hardware-configuration.nix ${dotfilesDir}/nix/nixhyper/.

    # build new config
    cprint -p "Rebuilding the system.."
    sudo nixos-rebuild boot --flake ${dotfilesDir}/nix/nixhyper/flake.nix#nixhyper
    cprint -p "Rebuild Complete! (hopefully..)"

    # rename .git back to normal
    sudo mv ${dotfilesDir}/.git.bak ${dotfilesDir}/.git

  # elif [ "$response" == "2" ]; then

  else
    cprint -p "Install Canceled"
    exit 0
  fi

# elif [[ "$os" == "mac" ]]; then

else
  cprint "This system version is not supported.."
  cprint "System is: \"$os\""
  exit 0
fi
################################################################################
# PACKAGES / SYSTEM ############################################################


# DOTFILES #####################################################################
################################################################################
# mappings (repo_path:home_path)
declare -A dotfiles=(
  ['dotfiles/zsh']='.config/zsh'
  ['dotfiles/nvim/nvim']='.config/nvim'
  ['dotfiles/nvim/coc']='.config/coc'
  ['dotfiles/tmux']='.config/tmux'
  ['dotfiles/git/gitconfig']='.gitconfig'
  ['dotfiles/alacritty']='.config/alacritty'
  ['bin']='bin'
  # Add more mappings here
)

# Process all dotfiles
for repo_path in "${!dotfiles[@]}"; do
  link_dotfile "$repo_path" "${dotfiles[$repo_path]}"
done

# link zshrc to .config/zsh
cprint -p "Create the .zshrc redirect"
echo "source ${homeDir}/.config/zsh/init.zsh" > ${homeDir}/.zshrc

# install zsh plugins
cprint -p "Zsh plugins are installed on first zsh launch"

# install nvim plugins
cprint -p "Install nvim plugins"
mkdir -p ${homeDir}/.local/share/nvim/plugins
git clone https://github.com/junegunn/vim-plug ${homeDir}/.local/share/nvim/plugins/vim-plug
nvim --headless -c "PlugInstall" -c "TSUpdateSync" -c "qall"
mkdir -p ${homeDir}/.config/coc/extensions/
backup_or_remove ${homeDir}/.config/coc/extensions/package.json
ln -s ${dotfilesDir}/dotfiles/nvim/nvim/coc-settings.json ${homeDir}/.config/coc/extensions/package.json

# install tmux plugins
cprint -p "Install tmux plugins"
mkdir -p ${homeDir}/.local/share/tmux/plugins
git clone https://github.com/tmux-plugins/tpm ${homeDir}/.local/share/tmux/plugins/tpm
tmux new-session -d -s temp_session "tmux source-file ${homeDir}/.config/tmux/tmux.conf && ${homeDir}/.local/share/tmux/plugins/tpm/scripts/install_plugins.sh"
################################################################################
# DOTFILES #####################################################################


cprint -p "Finished installing!"
