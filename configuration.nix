# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# ❄️

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # This is great for quick and easy config
      # But I have backported this into my own config
      #<nixos-hardware/dell/xps/13-9360>
    ];

  # The encrypted disk that should be opened before the root filesystem is mounted
  boot.initrd.luks.devices =
    [
      {
        name = "root";
        device = "/dev/nvme0n1p2";
        # luksOpen will be attempted before LVM scan
        preLVM = true;
      }
    ];

  # systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;
  #systemd.enableEmergencyMode = false;  # Start up no matter what, if at all possible.

  # Plymouth boot splash screen
  boot.plymouth.enable = true;

  # Clear /tmp during boot
  boot.cleanTmpDir = true;

  # https://wiki.archlinux.org/index.php/Kernel_mode_setting#Early_KMS_start
  boot.initrd.kernelModules = [ "i915" ];
  # Enable framebuffer compression (FBC)
  # can reduce power consumption while reducing memory bandwidth needed for screen refreshes.
  # https://wiki.archlinux.org/index.php/intel_graphics#Framebuffer_compression_(enable_fbc)
  boot.kernelParams = [ "i915.enable_fbc=1" ];

  # Use Linux 5.0.x instead of 4.19.x
  # boot.kernelPackages will use linuxPackages by default, so no need to define it
  nixpkgs.config.packageOverrides = in_pkgs :
    {
      linuxPackages = in_pkgs.linuxPackages_5_0;
    };

  # No access time and continuous TRIM for SSD
  fileSystems."/".options = [ "noatime" "discard" ];

  # If non-empty, write log messages to the specified TTY device.
  services.journald.console = "/dev/tty12";

  # Enable microcode updates for Intel CPU
  hardware.cpu.intel.updateMicrocode = true;
  # Enable Kernel same-page merging
  #hardware.enableKSM = true;

  # Enable all the firmware
  hardware.enableAllFirmware = true;
  # Enable all the firmware with a license allowing redistribution. (i.e. free firmware and firmware-linux-nonfree)
  hardware.enableRedistributableFirmware = true;

  # Enable OpenGL drivers
  hardware.opengl.enable
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];

  # Sysctl params
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288; # Allow VS Code to watch more files
  };

  # A DBus service that allows applications to update firmware
  services.fwupd.enable = true;

  # Check S.M.A.R.T status of all disks and notify in case of errors
  services.smartd = {
    enable = true;
    # Monitor all devices connected to the machine at the time it's being started
    autodetect = true;
    notifications = {
      x11.enable = if config.services.xserver.enable then true else false;
      wall.enable = true; # send wall notifications to all users
    };
  };

  # Add the NixOS Manual on virtual console 8
  services.nixosManual.showManual = true;

  networking.hostName = "nixpsla";
  networking.networkmanager.enable = true;

  # Simple stateful dual-stack firewall
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [];
    allowedUDPPorts = [];
    logRefusedConnections = true;
  };

  # The list of nameservers. It can be left empty if it is auto-detected through DHCP.
  #networking.nameservers = [ "1.0.0.1", "1.1.1.1" ];

  # DNSCrypt
  #services.dnscrypt-proxy.enable = true;
  #networking.nameservers = ["127.0.0.1"];

  # Network usage statistics
  services.vnstat.enable = true;

  i18n = {
    consoleFont = "latarcyrheb-sun32"; # Big console font for HiDPI
    consoleKeyMap = "fr";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Paris";

  # Use the systemd-timesyncd SNTP client to sync the system clock (enabled by default)
  services.timesyncd.enable = true;

  # Disable sudo password for the wheel group
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Utils
    wget neofetch micro ncdu gparted ntfs3g ripgrep file htop
    speedtest-cli strace awscli gitAndTools.diff-so-fancy freerdp
    google-cloud-sdk vault exa lazygit bat libsForQt5.vlc jq
    gparted tree rsync openssl bind
    # Nix tools
    nix-du #https://github.com/symphorien/nix-du
    # Dev
    vscode nodejs-11_x ruby_2_6 php73 python27Full python37Full
    jetbrains.webstorm shellcheck git
    # Else
    google-chrome spotify slack filezilla firefox ansible
    terraform tdesktop libreoffice gimp
    # VM
    open-vm-tools
    # Hardware
    lshw
    usbutils
    pciutils
    dmidecode
    lm_sensors
    smartmontools

    # https://www.mpscholten.de/nixos/2016/04/11/setting-up-vim-on-nixos.html
    (
      with import <nixpkgs> {};

      vim_configurable.customize {
        # Specifies the vim binary name
        # E.g. set this to "my-vim" and you need to type "my-vim" to open this vim
        # This allows to have multiple vim packages installed (e.g. with a different set of plugins)
        name = "vim";
        vimrcConfig.customRC = ''
          syntax on
          syntax enable

          set backupdir=/tmp      " save backup files (~) to /tmp

          set tabstop=4           " number of visual spaces per TAB
          set softtabstop=4       " number of spaces in tab when editing
          set expandtab           " tabs are spaces
          filetype indent on      " load filetype-specific indent files
          filetype on             " Enable file type detection

          set number              " show line numbers
          set showcmd             " show command in bottom bar
          set cursorline          " highlight current line
          set wildmenu            " visual autocomplete for command menu
          set lazyredraw          " redraw only when we need to.
          set showmatch           " highlight matching [{()}]

          set incsearch           " search as characters are entered
          set hlsearch            " highlight matches
          colorscheme pablo
          set backspace=indent,eol,start " backspace over everything in insert mode
        '';
      }
    )
  ];

  # Install + setcap
  programs.iftop.enable = true;
  programs.iotop.enable = true;
  programs.mtr.enable = true;

  # Thermals and cooling
  services.thermald.enable = true;
  # This includes support for suspend-to-RAM and powersave features on laptops
  powerManagement.enable = true;
  # Enable powertop auto tuning on startup.
  powerManagement.powertop.enable = true;
  # IDK if TLP is useful/conflicts with powerManagement
  #services.tlp.enable = true;

  # Install and configure Docker
  virtualisation.docker = {
    enable = true;
    # Run docker system prune -f periodically
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
    # Don't start the service at boot, use systemd socker activation
    enableOnBoot = false;
  };
  # Install LXD
  virtualisation.lxd.enable = true;
  # Install VB
  #services.virtualbox.enable = true;

  # Periodically update the database of files used by the locate command
  services.locate.enable = true;

  # Enable Flatpak
  #services.flatpak.enable = true
  # No snap yet: https://github.com/NixOS/nixpkgs/issues/30336

  # Enable ClamAV, an open source antivirus engine
  services.clamav.daemon.enable = true;
  # Enable ClamAV freshclam updater.
  services.clamav.updater.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the OpenSSH daemon.
  #services.openssh.enable = true;

  # Monitoring
  services.netdata = {
   enable = true;
   config = {
     global = {
       "default port" = "19999";
       "bind to" = "127.0.0.1";
     };
   };
  };

  # TODO: Restic backups
  # services.restic.backups

  # TODO OpenVPN
  # services.openvpn.servers


  # Enable Pulseaudio
  hardware.pulseaudio = {
    enable = true;

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

  # Bluetooth
  # https://nixos.wiki/wiki/Bluetooth
  hardware.bluetooth.enable = true;
  # Don't power up the default Bluetooth controller on boot
  hardware.bluetooth.powerOnBoot = false;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # GNOME
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  # GDM uses wayland by default, but I don't want to
  services.xserver.displayManager.gdm.wayland = false;

  # Remove these packages that come by default with GNOME
  environment.gnome3.excludePackages = with pkgs.gnome3; [
    epiphany
    evolution
    gnome-maps
    accerciser
  ];

  # Enable GNOME Keyring daemon
  services.gnome3.gnome-keyring.enable = true;
  # Enable Chrome GNOME Shell native host connector
  # This is a DBus service allowing to install GNOME Shell extensions from a web browser.
  services.gnome3.chrome-gnome-shell.enable = true;

  # this is required for mounting android phones
  # over mtp://
  services.gnome3.gvfs.enable = true;

  # Disable mutable users.
  #users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stanislas = {
    description = "Stanislas";
    # This automatically sets group to users, createHome to true,
    # home to /home/username, useDefaultShell to true, and isSystemUser to false.
    isNormalUser = true;
    # Use fish as the default shell
    shell = pkgs.fish;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker" "lxd" # Allow access to the sockets without root
    ];
    # It is possible to install packages on a per-user basis.
    # I don't know why I would do that so they are installed globally for now.
    #packages = [];
  };

  environment.variables.EDITOR = "vim";

  # Allow "unfree" packages.
  nixpkgs.config.allowUnfree = true;

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      inconsolata
      fira-code
      fira-mono
      corefonts  # Microsoft free fonts.
      inconsolata  # Monospaced.
      ubuntu_font_family  # Ubuntu fonts.
      unifont # some international languages.
      ipafont # Japanese.
      roboto # Android
    ];
  };

  nix = {
    # Automatically run the garbage collector
    gc.automatic = true;
    gc.dates = "12:45";
    # Automatically run the nix store optimiser
    optimise.automatic = true;
    optimise.dates = [ "12:55" ];
    # Nix automatically detects files in the store that have identical contents, and replaces them with hard links to a single copy.
    autoOptimiseStore = true;
    # maximum number of concurrent tasks during one build
    buildCores = 4;
    # maximum number of jobs that Nix will try to build in parallel
    # "auto" is broken: https://github.com/NixOS/nixpkgs/issues/50623
    maxJobs = 4;
    # perform builds in a sandboxed environment
    useSandbox = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  # This does NOT define the NixOS version. The channel does.
  # https://nixos.wiki/wiki/FAQ#When_do_I_update_stateVersion
  system.stateVersion = "19.03"; # Did you read the comment?

  # This will run nixos-rebuild switch --upgrade periodically
  #system.autoUpgrade.enable = true;

    # Use the fish shell.
  programs.fish = {
    enable = true;

    shellAliases = {
      sysrs = "sudo nixos-rebuild switch";
      # Same as nix-channel --update nixos; nixos-rebuild switch
      sysup = "sudo nixos-rebuild switch --upgrade";
      sysclean = "sudo nix-collect-garbage -d; and sudo nix-store --optimise";
      lgit = "git add -A; and git commit; and git push";
      lgitf = "git add -A; and git commit; and git pull; and git push";
      cat = "bat -p";
      ls = "exa -gF --group-directories-first";
      ll = "ls -l";
      l = "ll -a";
      grep = "rg";
      rgrep = "grep";
    };

    shellInit = ''
      # Remove welcome message
      set fish_greeting
    '';
  };

  programs.tmux = {
    enable = true;
    extraTmuxConf = ''
      # More history
      set -g history-limit 100000

      # Windows start at 1
      set -g base-index 1

      # Basic status bar colors
      set -g status-bg black
      set -g status-fg cyan
      set -g status-left-bg black
      set -g status-left-fg green
      set -g status-left-length 40
      #set -g status-left "Session #S #[fg=white]#[fg=yellow]Windows #I #[fg=cyan]Pane #P"
      set -g status-left "#S #[fg=white]#[fg=yellow]#I #[fg=cyan]#P"

      # Right side of status bar
      set -g status-right-bg black
      set -g status-right-fg cyan
      set -g status-right-length 40
      set -g status-right "#H #[fg=white]#[fg=yellow]%H:%M:%S #[fg=green]%d-%b-%y"

      # Window status
      set -g window-status-format " #I:#W "
      set -g window-status-current-format " #I:#W "

      # Current window status
      set -g window-status-current-bg red
      set -g window-status-current-fg black

      # Window with activity status
      set -g window-status-activity-bg yellow # fg and bg are flipped here due to a
      set -g window-status-activity-fg black  # bug in tmux

      # Window separator
      set -g window-status-separator ""

      # Window status alignment
      set -g status-justify centre

      # Screen like binding
      set -g prefix C-a
      bind a send-prefix

      # Enable mouse mode
      set -g mouse on
    '';
  };
}
