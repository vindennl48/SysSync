#!/bin/sh

# Define essential variables
dotfilesDir="$(cd "$(dirname "$0")" && pwd)"
homeDir="$HOME"
username="$(id -un)"

echo "--> Installing Dotfiles Lite.."

echo "    For this to work you need to install the following:"
echo "    neovim gcc nodejs yarn xclip tmux zsh"
echo "    As well as changing the shell: chsh -s \$(which zsh)"
echo "    "
echo "    For Arch and Pyenv.. Make sure you install Make and run the pyenv"
echo "    installer."
echo "    \$ sudo pacman -Syu make"
echo "    \$ curl -fsSL https://pyenv.run | bash"
echo "    "

echo "--> Would you like to continue? [y/n]"
read -r response
if [ "$response" != "y" ]; then
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
  ['zsh/zshrc']='.zshrc'
  ['git/gitconfig']='.gitconfig'
  ['nvim']='.config/nvim'
  ['tmux']='.config/tmux'
  # Add more mappings here
)

# Process all dotfiles
for repo_path in "${!dotfiles[@]}"; do
  link_dotfile "$repo_path" "${dotfiles[$repo_path]}"
done

echo "--> Finished installing Dotfiles Lite!"
