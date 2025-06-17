# users/blfnix.nix
{ pkgs, config, lib, inputs, flake-root, ... }:

let
    sucklessConfigsDir = flake-root + "/suckless-configs";

  buildCustomSucklessTool = {
    pname, version, toolName,
    patches ? [],
    buildInputs ? [],
    nativeBuildInputs ? [], # Allow overriding/extending nativeBuildInputs
    customConfigFileInSrc ? "config.def.h",
    makeUsesConfigFile ? "config.h",
    makeFlags ? [],
    meta ? {},
    # Allow passing phase overrides directly
    unpackPhase ? null, # If null, default stdenv unpackPhase for src is used
    preparePhase ? null,
    configurePhase ? null, # We'll define a default one below if not overridden
    buildPhase ? null,
    installPhase ? null  # We'll define a default one below if not overridden
  }:

  pkgs.stdenv.mkDerivation ({
    inherit pname version patches; # src is defined below

    src = sucklessConfigsDir + "/${toolName}";

    # Default phases can be overridden by passing them as arguments
    # If unpackPhase is not provided, stdenv's default is used (which should copy local dir)
    # If it IS provided, it's used.
    # Forcing our unpackPhase here was due to previous errors, let's try without first,
    # assuming stdenv default copy for local src is now working.
    # If "do not know how to unpack" returns, use this explicit unpackPhase:
    # phases = lib.optional (unpackPhase != null) "unpackPhase" ++ ["patchPhase" /* ... other phases */ ];
    # unpackPhase = if unpackPhase != null then unpackPhase else ''
    #   runHook preUnpack
    #   echo "Default stdenv src copy used, or custom unpackPhase if provided."
    #   # If still issues with src not being in PWD, use: cp -rT ${src}/. .
    #   runHook postUnpack
    # '';
    # For now, let's simplify and assume default src handling is fine.

    nativeBuildInputs = [ pkgs.gnumake pkgs.pkg-config ] ++ nativeBuildInputs;
    buildInputs = (with pkgs.xorg; [ libX11 libXft xorgproto ]) ++ buildInputs;

    CC = "${pkgs.llvmPackages_20.clang}/bin/clang";
    NIX_CFLAGS_COMPILE = toString ([ "-Wno-deprecated-declarations" ] ++ (if pkgs.stdenv.isDarwin then [] else [ "-Wno-unused-result" ]));

    # Use the provided configurePhase, or our default one
    configurePhase = if configurePhase != null then configurePhase else ''
      runHook preConfigure
      if [ -f ./${customConfigFileInSrc} ]; then
        echo "Copying customized ./${customConfigFileInSrc} to ./${makeUsesConfigFile} for ${pname}"
        rm -f ./${makeUsesConfigFile}
        cp ./${customConfigFileInSrc} ./${makeUsesConfigFile}
      else
        echo "Warning: Custom config file ./${customConfigFileInSrc} not found in $PWD for ${pname}."
      fi
      runHook postConfigure
    '';

    # Default buildPhase is 'make ${makeFlags}'. Pass makeFlags.
    makeFlags = [ "CC=${pkgs.llvmPackages_20.clang}/bin/clang" ] ++ makeFlags;
    
    # Default installPhase is 'make install ${installFlags}'. Pass installFlags.
    # If a custom installPhase is provided, it's used instead.
    installFlags = [ "PREFIX=$(out)" ];
    installPhase = if installPhase != null then installPhase else null; # Use default if not overridden

    meta = lib.recursiveUpdate { /* ... */ } meta;
  });

  myDWM = buildCustomSucklessTool {
    pname = "dwm-blfnix"; version = "6.5-blfnix-custom"; toolName = "dwm";
    buildInputs = with pkgs.xorg; [ libXinerama libXrandr ];
    customConfigFileInSrc = "config.def.h"; makeUsesConfigFile = "config.h";
  };

  myST = buildCustomSucklessTool {
    pname = "st-blfnix";
    version = "0.9.2-blfnix-custom";
    toolName = "st";
    nativeBuildInputs = [ pkgs.ncurses ]; 
    buildInputs = with pkgs; [
      harfbuzz fribidi fontconfig freetype xorg.libXext
    ];
    customConfigFileInSrc = "config.def.h";
    makeUsesConfigFile = "config.h";

    installPhase = ''
      runHook preInstall

      # Create terminfo directory with write permissions
      mkdir -p "$out/share/terminfo"
      chmod -R u+w "$out/share/terminfo"

      # Use TERMINFO env var to control installation path
      export TERMINFO="$out/share/terminfo"
      make install PREFIX="$out"

      runHook postInstall
  '';
  };

  myDMenu = buildCustomSucklessTool {
    pname = "dmenu-blfnix"; version = "5.3-blfnix-custom"; toolName = "dmenu";
    buildInputs = [ pkgs.xorg.libXinerama ];
    customConfigFileInSrc = "config.def.h"; makeUsesConfigFile = "config.h";
  };

  mySLStatus = buildCustomSucklessTool {
    pname = "slstatus-blfnix"; version = "1.1-blfnix-custom"; toolName = "slstatus";
    # Assuming for slstatus, you also customize config.def.h, and its Makefile
    # will generate config.h from it. If slstatus uses config.h directly and
    # you edit that in your source, change customConfigFileInSrc to "config.h".
    customConfigFileInSrc = "config.def.h"; # Standardize on this
    makeUsesConfigFile = "config.h";
  };

  # NixOS system installation (system package)
  # mySLock = buildCustomSucklessTool {
    # pname = "slock-blfnix"; version = "1.5-blfnix-custom"; toolName = "slock";
    # buildInputs = [ pkgs.shadow pkgs.xorg.libXrandr pkgs.xorg.libXext pkgs.libxcrypt ];
    # customConfigFileInSrc = "config.def.h"; makeUsesConfigFile = "config.h";
  # };
        
  # Xresources configuration (now more generic)
  xresourcesConfig = ''
    ! ~/.Xresources for blfnix
    Xft.autohint: 0
    Xft.lcdfilter: lcddefault
    Xft.hintstyle: hintslight
    Xft.hinting: 1
    Xft.antialias: 1
    Xft.rgba: rgb

    Xcursor.theme: Adwaita
    Xcursor.size: 12

    *faceName: monospace
    *faceSize: 9
    *cursorBlink: false
    *saveLines: 10000
    *selectToClipboard: true
    ! Normal cut & paste key conventions ( ctrl-shift c/v )
    *VT100.Translations: #override \
    Ctrl Shift <Key>V:    insert-selection(CLIPBOARD) \n\
    Ctrl Shift <Key>C:    copy-selection(CLIPBOARD) \n\

    ! Optional: Generic Xterm colors if some apps use them as fallback
    ! st will primarily use colors defined in its config.h
    *.background:   #242424
    *.foreground:   #dedede
    *.cursorColor:  #f0f0f0
    *.color0:       #1e1e1e
    *.color1:       #c01c28
    *.color2:  #2ec27e
    *.color3:  #e5a50a
    *.color4:  #3584e4
    *.color5:  #813d9c
    *.color6:  #33d7a0
    *.color7:  #dedede
    *.color8:  #5e5c64
    *.color9:  #ed333b
    *.color10: #57e389
    *.color11: #f8e45c
    *.color12: #62a0ea
    *.color13: #9141ac
    *.color14: #57d7a0
    *.color15: #ffffff
  '';

  # We construct the correct data path by referring to the packages
  # that are ALREADY in the system configuration. We do not add them here.
  # correctXdgDataDirs = pkgs.lib.makeSearchPath "share" [
    # pkgs.gsettings-desktop-schemas
    # pkgs.xdg-desktop-portal-gtk
    # pkgs.gtk3
    # pkgs.gtk4
  # ];  

in {
  home.username = "blfnix";
  home.homeDirectory = "/home/blfnix";
  home.stateVersion = "25.05";

  # This is the declarative way to add directories to your PATH.
  # It correctly appends to the path without breaking other environment variables.
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  home.packages = with pkgs; [
    # === Custom Suckless Tools (slock removed) ===
    myDWM myDMenu mySLStatus myST # mySLock is now a system package

    # === X Utilities for dwm session ===
    picom feh xautolock xorg.xev polkit_gnome
    # === General Desktop Apps & CLI Utilities ===
    p7zip gnupg pinentry-tty curl file tree sqlite xdg-utils mpv
    ffmpeg cmus qbittorrent gimp3 libreoffice simple-scan scrot
    thunderbird brave

    # === Network tools ===
    nmap wireshark

    # === system-level configuration file - must be at system level ===
    # Core GTK/GSettings functionality. Installing these at the system-level
    # ensures the environment (XDG_DATA_DIRS) is constructed correctly for all users.
    # glib                        # Provides the gsettings CLI tool
    # gsettings-desktop-schemas   # Provides base desktop schemas
    # xdg-desktop-portal-gtk      # Provides GTK4 portal backend and schemas
    # gtk3                        # Provides GTK3 schemas
    # gtk4                        # Provides GTK4 schemas

    # === Helix Editor and its LSPs/Formatters ===
    helix
    marksman ruff nodePackages.typescript-language-server
    nodePackages.vscode-json-languageserver nodePackages.yaml-language-server
    taplo bash-language-server nil
    dprint shfmt nixpkgs-fmt
    #
    # pyright
    # stylua # Add if you edit Lua and want Helix to format it
    # python313Packages.black # Add if ruff is not enough for Python formatting

    # === Core Development Toolchains ===
    rustup python313 uv nodejs_24 zig zls zsh-autocomplete

    # === Build Tools ===
    cmake ninja gnumake
    llvmPackages_20.clang llvmPackages_20.llvm llvmPackages_20.lld
    llvmPackages_20.clang-tools llvmPackages_20.lldb

    # === Other CLI Tools & AI Tools ===
    tmux pass keychain git gh fd ripgrep bat jq xclip yazi lshw
    ueberzugpp unar ffmpegthumbnailer poppler_utils w3m zathura
    aider-chat litellm
    pulseaudio # Provides pactl and other PulseAudio client utilities
    htop
  ];


  # --- Xresources (Managed by Home Manager at ~/.config/Xresources) --- 
  home.file.".Xresources" = {
    text = xresourcesConfig;
  };

  # --- .xinitrc to start your custom dwm session ---
  home.file.".xinitrc" = {
  text = ''
    #!/usr/bin/env sh

    # Load system environment
    [ -f /etc/profile ] && . /etc/profile

    # Theme setup is now handled by sessionVariables
    export GTK_THEME QT_STYLE_OVERRIDE XCURSOR_THEME XCURSOR_SIZE

    # Compile GSettings schemas
    mkdir -p "$HOME/.local/share/glib-2.0/schemas"
    export XDG_DATA_DIRS="${config.home.sessionVariables.XDG_DATA_DIRS}"
    ${pkgs.glib.bin}/bin/glib-compile-schemas "$HOME/.local/share/glib-2.0/schemas"
      
    # Load Xresources
    [ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

    # Compositor
    picom --daemon &

    # Wallpaper
    feh --bg-scale "$HOME/.wallpapers/mighty_trees_road.jpg" &

    # PolicyKit agent
    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

    # Auto‑lock after 10 min
    xautolock -time 10 -locker slock &

    # Start systemd user instance
    if command -v systemctl >/dev/null; then
      systemctl --user start graphical-session.target
    fi

    # Status bar
    ( while true; do slstatus; sleep 1; done ) &

    # Finally start dwm under dbus
    # exec dbus-launch --exit-with-session dwm
    # Replace dbus-launch with proper systemd integration
    exec systemd-cat --identifier=dwm dwm
  '';
  executable = true;
};

  # --- ZSH CONFIGURATION ---
  programs.zsh = {
    enable = true;
    # Use 'profileExtra' for content added to ~/.zprofile (for login shells)
      profileExtra = ''
    # Start X server automatically if on tty1 and no X session is running
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      if ! pgrep -x Xorg > /dev/null && ! pgrep -x Xwayland > /dev/null; then
        startx
      fi
    fi
  '';
    
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    completionInit = "autoload -U compinit && compinit";
    plugins = [{ name = "zsh-autocomplete"; src = pkgs.zsh-autocomplete; }];
    shellAliases = {
      ls = "ls --color=auto -F";
      ll = "ls -alhF";
      la = "ls -AF";
      l = "ls -CF";
      glog = "git log --oneline --graph --decorate --all";
      nix-update-system = "sudo nixos-rebuild switch --flake ${flake-root}#nixos"; # Using flake-root
      # nix-update-system = "sudo nixos-rebuild switch --flake ~/Utveckling/NixOS#nixos"; # Your Flake path
      cc = "clang";
      cxx = "clang++";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 10000;
    };
    initContent = ''
      bindkey -v # Enable Vi Keybindings

      # === BAD SETTINGS - INTERFERING WITH SYSTEM ENV - AVOID! ===
      # Correct way - see above
      # export PATH="$HOME/.cargo/bin:$PATH"
      # export PATH="$HOME/.local/bin:$PATH"
      # export PATH="$HOME/.npm-global/bin:$PATH"

      export KEYTIMEOUT=150

      # Custom Functions (ensure these are fully defined from your working config)
      multipull() {
        local BASE_DIR=~/.code
        if [[ ! -d "$BASE_DIR" ]]; then echo "multipull: Base dir $BASE_DIR not found" >&2; return 1; fi
        echo "Searching Git repos under $BASE_DIR..."
        fd --hidden --no-ignore --type d '^\.git$' "$BASE_DIR" | while read -r gitdir; do
          local workdir=$(dirname "$gitdir")
          echo -e "\n=== Updating $workdir ==="
          if (cd "$workdir" && git rev-parse --abbrev-ref --symbolic-full-name '@{u}' &>/dev/null); then
            git -C "$workdir" pull
          else
            local branch=$(git -C "$workdir" rev-parse --abbrev-ref HEAD)
            echo "--- Skipping pull (no upstream for branch: $branch) ---"
          fi
        done
        echo -e "\nMultipull finished."
      }
      _activate_venv() {
        local venv_name="$1"; local venv_activate_path="$2"
        if [[ ! -f "$venv_activate_path" ]]; then echo "Error: Venv script $venv_activate_path not found" >&2; return 1; fi
        if (( $+commands[deactivate] )) && [[ "$(type -t deactivate)" != "builtin" ]]; then deactivate; fi
        . "$venv_activate_path" && echo "Activated venv: $venv_name"
      }
      v_mlmenv() { _activate_venv "mlmenv (Python 3.13)" "$HOME/.venv/python3.13/mlmenv/bin/activate"; }
      v_crawl4ai() { _activate_venv "crawl4ai (Python 3.13)" "$HOME/.venv/python3.13/crawl4ai/bin/activate"; }
    '';
  };

  # --- APPLICATION CONFIGURATIONS ---
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      directory = { truncation_length = 3; truncation_symbol = "…/"; };
    };
  };

  # programs.helix.enable = true; # This HM module is for basic settings;
  # we use xdg.configFile for full control.

  programs.keychain = { enable = true; agents = [ "ssh" ]; keys = [ "id_ecdsa" ]; };

  programs.git = {
    enable = true;
    userName = "Bengt Frost";
    userEmail = "bengtfrost@gmail.com";
    extraConfig = { core.editor = "hx"; init.defaultBranch = "main"; }; # Editor changed to hx
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" "--prompt='➜  '" ];
  };

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      adjust-open = "best-fit";
      default-bg = "#212121";
      default-fg = "#303030";
      statusbar-fg = "#B2CCD6";
      statusbar-bg = "#353535";
      inputbar-bg = "#212121";
      inputbar-fg = "#FFFFFF";
      notification-bg = "#212121";
      notification-fg = "#FFFFFF";
      notification-error-bg = "#212121";
      notification-error-fg = "#F07178";
      notification-warning-bg = "#212121";
      notification-warning-fg = "#F07178";
      highlight-color = "#FFCB6B";
      highlight-active-color = "#82AAFF";
      completion-bg = "#303030";
      completion-fg = "#82AAFF";
      completion-highlight-fg = "#FFFFFF";
      completion-highlight-bg = "#82AAFF";
      recolor-lightcolor = "#212121";
      recolor-darkcolor = "#EEFFFF";
      recolor = false;
      recolor-keephue = false;
    };
  };

  /* Commented out, st is primary terminal
  # --- Alacritty Configuration ---
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";

      window = {
        # Set initial window dimensions (columns x lines)
        dimensions = { columns = 83; lines = 25; }; # ADDED/MODIFIED

        padding = { x = 0; y = 0; };
        dynamic_title = true;
        # decorations = "full"; # Keep as "full" for XFCE to draw decorations
      };

      scrolling.history = 10000;

      font = {
        normal = { family = "Cousine Nerd Font Mono"; style = "Regular"; };
        bold = { family = "Cousine Nerd Font Mono"; style = "Bold"; };
        italic = { family = "Cousine Nerd Font Mono"; style = "Italic"; };
        bold_italic = { family = "Cousine Nerd Font Mono"; style = "Bold Italic"; };
        size = 9.0; # Or the size that worked best for you
      };

      cursor = {
        style = { shape = "Block"; blinking = "Off"; };
      };

      colors = {
        primary = { background = "0x242424"; foreground = "0xdedede"; };
        cursor = { text = "CellBackground"; cursor = "0xf0f0f0"; };
        normal = {
          black = "0x1e1e1e";
          red = "0xc01c28";
          green = "0x26a269";
          yellow = "0xa2734c";
          blue = "0x12488b";
          magenta = "0xa347ba";
          cyan = "0x258f8f";
          white = "0xa0a0a0";
        };
        bright = {
          black = "0x4d4d4d";
          red = "0xf66151";
          green = "0x33d17a";
          yellow = "0xf8e45c";
          blue = "0x3584e4";
          magenta = "0xc061cb";
          cyan = "0x33c7de";
          white = "0xf0f0f0";
        };
      };

      bell = {
        animation = "EaseOutExpo";
        duration = 100;
      };

      mouse.hide_when_typing = true;

      # Shell
      # shell = { program = "${pkgs.zsh}/bin/zsh", args = ["-l"] };
    };

  };
  */

  # --- HELIX CONFIGURATION (via dotfiles) ---
  xdg.configFile."helix/languages.toml".source = ../dotfiles/helix/languages.toml;
  xdg.configFile."helix/config.toml".source = ../dotfiles/helix/config.toml;

  # --- GTK Themeing (Manual, for minimal WMs) ---
  # This replaces the home-manager gtk module to avoid dconf issues.
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-icon-theme-name=Adwaita
    gtk-font-name=Arimo Nerd Font 9
    gtk-cursor-theme-name=Adwaita
    gtk-cursor-theme-size=24
    gtk-application-prefer-dark-theme=true
  '';

  home.file.".gtkrc-2.0".text = ''
    include "${config.xdg.configHome}/gtk-3.0/settings.ini"
  '';

  # --- GTK4 Settings ---
  xdg.configFile."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-icon-theme-name=Adwaita
    gtk-font-name=Arimo Nerd Font 9
    gtk-application-prefer-dark-theme=true
  '';

  # Qt Theme Configuration
  qt = {
    enable = true;
    platformTheme = {
      name = "adwaita"; # Was "gnome", now "adwaita" (or potentially "gtk2" if you preferred that style)
                       # "adwaita" will make Qt apps try to look like Adwaita.
                       # This often works well with qgnomeplatform or similar style engines.
      # package = pkgs.libsForQt5.qtstyleplugin-adwaita-dark; # Example if a specific adwaita platform theme package is needed
                                                              # Often just the name is enough if qgnomeplatform is used or if
                                                              # the style below covers it.
    };
    style = {
      name = "adwaita-dark"; # This sets the specific Qt style
      package = pkgs.adwaita-qt6; # This package provides the adwaita-dark Qt style
    };
    # It's also common to install qgnomeplatform for better integration if using platformTheme "adwaita" or "gnome"
    # Ensure pkgs.qgnomeplatform (or pkgs.libsForQt5.qgnomeplatform for Qt5 apps)
    # is in your home.packages if not pulled in by LXQt or your Qt style settings.
    # Your current home.packages list does not seem to include it explicitly,
    # but adwaita-qt6 might handle a lot of it.
  };

  # --- Home Manager Session Variables ---
  home.sessionVariables = {
    EDITOR = "hx"; VISUAL = "hx"; PAGER = "less";
    CC = "clang"; CXX = "clang++";
    GIT_TERMINAL_PROMPT = "1";
    FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git";
    TERMINAL = "${myST}/bin/st"; # Your custom ST
    BROWSER = "brave";

    # Consolidated theme variables
    GTK_THEME = "Adwaita-dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";

    # This is the DEFINITIVE FIX. We construct the correct schema path and
    # prepend it to the existing environment, ensuring all apps see it first.
    XDG_DATA_DIRS = let
      # List of all packages that provide schemas, which are installed in configuration.nix
      schemaPkgs = [
        pkgs.gsettings-desktop-schemas
        pkgs.gtk3
        pkgs.gtk4
        pkgs.xdg-desktop-portal-gtk
      # Add any other GTK apps here if they have their own schemas
      ];
      # Use a Nix function to build the correct search path string
      schemaPath = pkgs.lib.makeSearchPath "share" schemaPkgs;
    in "${schemaPath}:${builtins.getEnv "XDG_DATA_DIRS"}";
  };
  # Add this systemd service to handle schema compilation
  systemd.user.services.compile-gschemas = {
    Unit.Description = "Compile GSettings schemas";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.glib.bin}/bin/glib-compile-schemas ${config.home.homeDirectory}/.local/share/glib-2.0/schemas";
    };
    Install.WantedBy = ["default.target"];
  };

  # Add this to create a wrapper for gsettings
  home.file.".local/bin/gsettings-wrapper" = {
    text = ''
      #!/bin/sh
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:${pkgs.gtk4}/share/gsettings-schemas/${pkgs.gtk4.name}:${pkgs.xdg-desktop-portal-gtk}/share:/usr/share:/usr/local/share"
      exec ${pkgs.glib.bin}/bin/gsettings "$@"
    '';
    executable = true;
  };
}
