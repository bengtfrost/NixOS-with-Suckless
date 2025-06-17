# configuration.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-8e49ba55-1183-47f4-86af-d1a814d1ef3c".device = "/dev/disk/by-uuid/8e49ba55-1183-47f4-86af-d1a814d1ef3c";

  # Security Hardening
  boot.kernelParams = [
  "slab_nomerge"
  "init_on_alloc=1"
  "page_alloc.shuffle=1"
  ];

  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = false;  # Explicitly disabled for DWM

  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "sv_SE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8"; LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8"; LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8"; LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8"; LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    xkb = { 
      layout = "se";
      variant = "";
    };
  };
  console.keyMap = "sv-latin1";

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nix.settings = {
  experimental-features = ["nix-command" "flakes"];
  auto-optimise-store = true;
  trusted-users = ["root" "blfnix"];
  };
  
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    persistent = true;
    options = "--delete-older-than 30d";
    dates = "weekly";
  };
  
  programs.zsh.enable = true;

  users.users.blfnix = {
    isNormalUser = true;
    description = "Bengt Frost";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "wireshark" ];
    shell = pkgs.zsh;
    # packages = [ ];   # User packages are managed by Home Manager
  };

  # programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    wget gitMinimal fontconfig
    xorg.xinit xorg.xrdb xorg.xsetroot xorg.xev
    slock # Install slock system-wide from Nixpkgs
    brave

    # Core GTK/GSettings functionality. Installing these at the system-level
    # ensures the environment (XDG_DATA_DIRS) is constructed correctly for all users.
    glib                        # Provides the gsettings CLI tool
    gsettings-desktop-schemas   # Provides base desktop schemas
    xdg-desktop-portal-gtk      # Provides GTK4 portal backend and schemas
    gtk3                        # Provides GTK3 schemas
    gtk4                        # Provides GTK4 schemas
  ];

  # Ensure DBus and polkit are enabled
  services.dbus.enable = true;
  security.polkit.enable = true;

  environment.etc."profile.d/gsettings-wrapper.sh" = {
  text = ''
    #!/bin/sh
    # System-wide wrapper for gsettings
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:${pkgs.gtk4}/share/gsettings-schemas/${pkgs.gtk4.name}:${pkgs.xdg-desktop-portal-gtk}/share:/usr/share:/usr/local/share:$XDG_DATA_DIRS"
    exec ${pkgs.glib.bin}/bin/gsettings "$@"
  '';
  mode = "0755";
  };

  # System-wide GTK dark theme (fallback)
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-icon-theme-name=Adwaita
    gtk-font-name=Arimo Nerd Font 9
    gtk-application-prefer-dark-theme=1
  '';

  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-icon-theme-name=Adwaita
    gtk-font-name=Arimo Nerd Font 9
    gtk-application-prefer-dark-theme=1
  '';

  security.wrappers.slock = { # The name of the command that will be wrapped
    source = "${pkgs.slock}/bin/slock"; # Path to the original binary
    owner = "root";
    group = "root"; # Or a specific group like "tty" or "shadow" if appropriate for slock's needs
    setuid = true;
  };
  # Note: Some simple SetUID programs might be automatically wrapped if they
  # have setuid = true; in their Nixpkgs derivation meta attributes.
  # Explicitly defining it in security.wrappers is robust.

    # Install all three Nerd Fonts
  fonts.packages = with pkgs; [ 
    nerd-fonts.fira-code    # Monospace
    nerd-fonts.tinos        # Serif
    nerd-fonts.arimo        # Sans
  ];

  # Set system-wide font defaults
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FiraCode Nerd Font Mono" ];
      sansSerif = [ "Arimo Nerd Font" ];
      serif = [ "Tinos Nerd Font" ];
    };
  };

  programs.gnupg.agent.enable = true;
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    
    # Completely disable publishing features
    publish = {
      enable = false;
      domain = false;
      userServices = false;
      workstation = false;
      addresses = false;
      hinfo = false;
    };

    # Explicit service configuration
    extraServiceFiles = {
      # Create empty service files for protocols we're not using
      smb = "${pkgs.writeText "smb.service" ""}";
      ssh = "${pkgs.writeText "ssh.service" ""}";
      sftp-ssh = "${pkgs.writeText "sftp-ssh.service" ""}";
    };
  };
  
  system.stateVersion = "25.05";
}
