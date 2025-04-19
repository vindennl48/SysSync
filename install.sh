#!/bin/sh
# Symlink dotfiles and install necessary packages

dotfilesDir="$(cd "$(dirname "$0")" && pwd)"
homeDir="$HOME"
username="$(id -un)"

source "$dotfilesDir/bin/lib"

cprint -p "Installing Dotfiles"

os=$(detect_os)
cprint "System is: $os"

cprint -p "Would you like to continue? [y/n]"
read -r response
if [ "$response" != "y" ]; then
  exit 0
fi

# installing required packages
if [[ "$os" == "arch" ]]; then
  cprint -p "Install Required Packages"
  sudo pacman -Syu neovim gcc make nodejs yarn xclip tmux zsh

  cprint -p "Installing pyenv"
  bash <(curl -fsSL https://pyenv.run)

  cprint -p "Change shell to zsh"
  chsh -s $(which zsh)
# elif [[ "$os" == "nix" ]]; then
# elif [[ "$os" == "mac" ]]; then
else
  cprint "This system version is not supported.."
  exit 0
fi

link_dotfile() {
  local repo_path="${dotfilesDir}/$1"
  local home_path="${homeDir}/$2"
  
  # Skip if symlink is already correct
  if [ -L "$home_path" ] && [ "$(readlink "$home_path")" = "$repo_path" ]; then
    echo "✓ Symlink '$home_path' already correct"
    return 0
  fi

  # Backup existing file/directory if not a symlink
  if [ -e "$home_path" ] && [ ! -L "$home_path" ]; then
    local backup_base="$home_path.bak"
    local backup_path="$backup_base"
    local timestamp=$(date +%Y%m%d%H%M%S)
    
    # Append timestamp if backup exists
    [ -e "$backup_base" ] && backup_path="$backup_base.$timestamp"
    
    echo "⚠ Backing up '$home_path' to '$backup_path'"
    mv -- "$home_path" "$backup_path"
  fi

  # Create parent directories if needed
  mkdir -p "$(dirname "$home_path")"

  # Create/update symlink
  echo "➔ Creating symlink: '$home_path' → '$repo_path'"
  ln -sfn "$repo_path" "$home_path"

  # Set correct user permissions
  echo "➔ Setting Permission: $(dirname "$home_path")"
  sudo chown "${username}:users" "$(dirname "$home_path")"

  echo "➔ Setting Permission: $home_path"
  sudo chown -h "${username}:users" "$home_path"
}

# Dotfile mappings (repo_path:home_path)
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
backup_or_remove ${homeDir}/.config/coc/extensions/package.json
ln -s ${dotfilesDir}/dotfiles/nvim/nvim/coc-settings.json ${homeDir}/.config/coc/extensions/package.json

# install tmux plugins
cprint -p "Install tmux plugins"
mkdir -p ${homeDir}/.local/share/tmux/plugins
git clone https://github.com/tmux-plugins/tpm ${homeDir}/.local/share/tmux/plugins/tpm
tmux new-session -d -s temp_session "tmux source-file ${homeDir}/.config/tmux/tmux.conf && ${homeDir}/.local/share/tmux/plugins/tpm/scripts/install_plugins.sh"

cprint -p "Finished installing!"
