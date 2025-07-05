# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ self, config, lib, pkgs, nix-homebrew, ... }:

{
  imports = [
    ./systemSettings.nix

    nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        # Install Homebrew under the default prefix
        enable = true;

        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        enableRosetta = true;

        # User owning the Homebrew prefix
        user = "mitch";
      };
    }
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    rsync # for macos symlink applications to spotlight
    # home-manager # use SysSync dotfiles instead
    vim
    neovim gcc nodejs yarn xclip
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
    tmux
    git
    appcleaner
    alacritty
    htop
    wget
    bat
    less
    tree
    lua-language-server
    spotify
    stats # mac status bar for cpu and ram, etc.
    ffmpeg
    google-chrome
    nh # nix command helper
    magic-wormhole
  ];

  homebrew = {
    enable = true;
    casks = [
      "1Password" # doesnt work for nix install
      "blackhole-2ch" # no version for nix
      "caffeine" # nix version is not M1 compatibile
      "ilok-license-manager" # no nix version
      "scroll-reverser" # no nix version
      "midi-monitor" # to sniff midi messsages
      "arduino-ide" # to edit arduino
      "vlc"
      "visual-studio-code"
      "displaylink"
    ];
    brews = [
      "pyenv" # having problems with the nix version and tk
      "python-tk@3.12" # no version for nix
      "switchaudio-osx" # switch audio sources for LOF
    ];
    masApps = {
      # dont care if these auto-update
      "1Password For Safari" = 1569813296;
      "Slack" = 803453959;
      "Hidden Bar" = 1452453066;
      "Remote Desktop" = 1295203466;
    };
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = ''
      # Changing Window Focus
      # ALT is actually option key
      
      cmd - 0 : open -a alacritty

      # cmd - 1 is set up thru macos keyboard shortcuts to desktop

      # cmd - 4 : open -a Safari
      cmd - 4 -> : open -a Safari

      # disable cmd-h to hide things
      # cmd - h : skhd -k ""
    '';
  };

  fonts.packages = with pkgs; [
    # (nerdfonts.override { fonts = [ "RobotoMono" "FiraCode" "DroidSansMono" "IBMPlexMono" ]; })
    pkgs.nerd-fonts.roboto-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nerd-fonts.blex-mono
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh = {
    enable = true;
    enableCompletion = true;  # ✅ Built-in option in Nix Darwin

    # Manually source autosuggestions and syntax highlighting
    interactiveShellInit = ''
      # Enable autosuggestions
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      # Enable syntax highlighting
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "macnix";
  nixpkgs.config.allowUnfree = true;

  users.users.mitch = {
      name = "mitch";
      home = "/Users/mitch";
  };
}
