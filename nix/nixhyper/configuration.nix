{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  ## HOST NAME ##
  networking.hostName = "nixhyper"; # has to be included
  hardware.cpu.intel.updateMicrocode = true;

  ## USERS ##
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixhyper = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  ## PACKAGES ##
  environment.systemPackages = with pkgs; [
    # system
    spice spice-gtk spice-protocol spice-vdagent
    virt-manager virt-viewer win-virtio win-spice pciutils virtiofsd
    looking-glass-client # version B7-rc1

    # general
    vim neovim htop wget git less tree
    gcc nodejs yarn xclip tmux vlc alacritty
    nh # helper for shortening nix commands
    nvd # helper for comparing nix versions and building new ones
    lua-language-server # since coc lua doesnt work right
    fzf # make sure to put this in .zshrc: eval "$(fzf --zsh)"

    # audio
    # qjackctl # GUI for controlling jack connections
  ];

  ## ADDITIONAL PACKAGES ##
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.firefox.enable = true;

  ## CODEIUM (needed to get codeium.vim to work) ##
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    codeium
  ];

  ## GUI ##
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";
  # services.xserver.displayManager.sddm.enable = true; # for GUI login menu
  services.xserver.displayManager.startx.enable = true; # to start at terminal
  services.xserver.desktopManager.plasma6.enable = true;

  ## REMOTE DESKTOP ##
  services.xrdp.enable = true;
  services.xrdp.openFirewall = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";

  ## FONTS ##
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "RobotoMono" "FiraCode" "DroidSansMono" "IBMPlexMono" ]; })
  ];

  ## SYSTEMD SERVICES ##
  systemd.targets.sleep.enable = false;
  systemd.targets.sleep.unitConfig.DefaultDependencies = "no";
  systemd.targets.suspend.enable = false;
  systemd.targets.suspend.unitConfig.DefaultDependencies = "no";
  systemd.targets.hibernate.enable = false;
  systemd.targets.hibernate.unitConfig.DefaultDependencies = "no";
  systemd.targets.hybrid-sleep.enable = false;
  systemd.targets.hybrid-sleep.unitConfig.DefaultDependencies = "no";
  # shim for looking-glass to work
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 nixhyper qemu-libvirtd -"
    "f /dev/shm/looking-glass 0660 nixhyper kvm -"
  ];

  ## ENV VARS ##
  environment.variables = {
    # EXAMPLE_VAR = true;
  };

  ## libvirt and virt-manager ##
  # programs.virt-manager.enable = true; # Install virt-manager
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.libvirtd.qemu.ovmf.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true;

  ## AUDIO ##
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true; # allow realtime audio
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.jack.enable = true;

  ## Network Bridge Setup ##
  systemd.network = {
    enable = true;
    wait-online.enable = false;
    netdevs = {
      "1-br0" = {
        enable = true;
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
      };
    };
    networks = {
      "2-br0-bind" = {
        matchConfig.Name = "enp6s0";
        networkConfig.Bridge = "br0";
      };
      "3-br0-dhcp" = {
        matchConfig.Name = "br0";
        networkConfig.DHCP = "ipv4";
      };
      # "20-wlan" = {
      #   matchConfig.Name = "wl*";
      #   linkConfig.RequiredForOnline = "routable";
      #   networkConfig.DHCP = "yes";
      #   networkConfig.MulticastDNS = "yes";
      # };
    };
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "br0" ];
  networking.firewall.allowedTCPPorts = [ 22 8000 5901 ];
  networking.nameservers = [ "192.168.1.1" ];
  networking.search = [ "local" ];

  ## OpenSSH ##
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.ports = [ 22 ];

  ## BLUETOOTH ##
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true; # bluetooth GUI

  ## BOOTLOADER ##
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "pcie_aspm=off"
      ''vfio-pci.ids="10de:2705,10de:22bb"''
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.availableKernelModules = [ "nvidiafb" "vfio-pci" ];
  boot.initrd.preDeviceCommands = ''
    DEVS="0000:01:00.0 0000:01:00.1"
    for DEV in $DEVS; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    modprobe -i vfio-pci
  '';

  ## TIMEZONE ##
  time.timeZone = "America/New_York";

  ## LOCALES ##
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_ADDRESS = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_IDENTIFICATION = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_MEASUREMENT = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_MONETARY = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_NAME = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_NUMERIC = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_PAPER = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TELEPHONE = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "en_US.UTF-8";

  ## SYSTEM ##
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # allow packages that cost money

  ## DO NOT TOUCH ##
  system.stateVersion = "24.05";
}
