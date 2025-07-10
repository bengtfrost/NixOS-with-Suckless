# Declarative Suckless Desktop on NixOS

<div align="center">

![NixOS Logo](https://img.shields.io/badge/NixOS-25.05-5277C3.svg?style=for-the-badge&logo=NixOS&logoColor=white)
![Suckless DWM](https://img.shields.io/badge/suckless-dwm-blue.svg?style=for-the-badge)
![Emacs](https://img.shields.io/badge/Emacs-29-7F5AB6.svg?style=for-the-badge&logo=GNU-Emacs&logoColor=white)
![Clojure](https://img.shields.io/badge/Clojure-CIDER-58B566.svg?style=for-the-badge&logo=Clojure&logoColor=white)

</div>

This repository contains a complete, declarative configuration for a minimal and powerful desktop environment on NixOS. It fuses the minimalist philosophy of the [suckless.org](https://suckless.org/) toolset with the reproducible and robust system management of NixOS, using Flakes and Home Manager. The primary development environment is a terminal-based **Emacs**, configured for a first-class interactive **Clojure** workflow.

The core principle is to treat the **manually prepared Suckless source code** as the definitive input for the system build. All patching and `config.def.h` customization is done by you, directly on the source files, *before* invoking the Nix build. Nix then takes these pre-customized sources and builds them within a pure environment, resulting in a fully reproducible, custom-tailored desktop environment.

## Screenshots

<p align="center">
  <img src="./assets/nix-suckless-desktop.png" width="48%" alt="Clean dwm desktop with slstatus bar"/>
  <img src="./assets/nix-suckless-apps.png" width="48%" alt="Desktop with st, Emacs, and a file manager"/>
</p>

## Table of Contents

- [Core Philosophy](#core-philosophy)
- [Features](#features)
- [System Structure](#system-structure)
- [The Declarative Suckless Build Process](#the-declarative-suckless-build-process)
- [Key Configuration Details](#key-configuration-details)
  - [Daemon-less GTK Theming](#daemon-less-gtk-theming)
  - [Declarative Emacs Configuration](#declarative-emacs-configuration)
  - [System Hardening and Optimization](#system-hardening-and-optimization)
- [Installation and Replication](#installation-and-replication)
- [Daily Workflow](#daily-workflow)

## Core Philosophy

This setup is born from two ideals:

1.  **Suckless:** Software that is simple, minimal, and does one thing well. The configuration is done by patching and editing the C source code directly.
2.  **NixOS:** A Linux distribution where the entire system configuration—from the kernel to packages to dotfiles—is defined in a set of declarative files. Builds are reproducible and atomic.

By combining them, we achieve the ultimate goal: a system where even our custom-patched window manager and terminal, alongside a fully configured Emacs IDE, are just another part of a single, version-controlled, reproducible configuration.

## Features

-   **Fully Declarative:** The entire system is managed by the Nix Flake in this repository.
-   **Custom Suckless Stack:** `dwm`, `st`, `dmenu`, and `slstatus` are all built from user-customized local source code.
-   **Modern Emacs IDE:** A minimal, terminal-based Emacs (`emacs-nox`) setup with powerful, discoverable keybindings and a focus on interactive Clojure development with CIDER.
-   **Shared Development Toolchain:** Language servers (`clojure-lsp`, `ruff`, `nil`) and formatters are managed by NixOS and shared between all tools.
-   **Robust, Daemon-less GTK Theming:** A clean, declarative solution ensures GTK2, GTK3, and GTK4 applications are themed correctly without relying on daemons.
-   **Home Manager:** Manages all user-level configuration, including dotfiles, packages, services, and the Emacs configuration itself.
-   **Minimalist Session Management:** Uses a declarative `~/.xinitrc` file to launch the `dwm` session via `startx`.

## System Structure

The repository is organized to clearly separate concerns, with a dedicated directory for the Emacs configuration.

```
.
├── flake.nix                 # The central entry point for the entire system build.
├── configuration.nix         # System-level NixOS settings (kernel, packages, etc.).
├── users/
│   └── blfnix.nix            # User-level config via Home Manager (packages, services).
├── suckless-configs/         # Raw source code for the suckless tools. Edit config.def.h here!
│   └── ...
├── dotfiles/                 # Static configuration files managed by Home Manager.
│   └── emacs/                # Modular Emacs configuration in Lisp.
│       ├── init.el
│       └── lisp/
│           ├── clojure.el
│           ├── keybinds.el
│           ├── langs.el
│           └── ui.el
└── assets/                   # Screenshots for the README.
    └── ...
```

-   **`flake.nix`**: Defines the project's inputs (nixpkgs, home-manager) and orchestrates the build.
-   **`configuration.nix`**: Defines the machine, including system-wide packages, fonts, and security settings.
-   **`users/blfnix.nix`**: Defines the user environment, containing the Suckless build logic and installing all user-level packages like Emacs and its language tools.
-   **`suckless-configs/`**: Holds the source code for each suckless tool, which you modify directly.
-   **`dotfiles/emacs/`**: Contains the modular Emacs configuration, which is symlinked into `~/.config/emacs` by Home Manager.

## The Declarative Suckless Build Process

The magic happens in `users/blfnix.nix`. A custom Nix function builds the suckless tools from your manually prepared source code.

-   **Your Role (Manual Preparation):** Before building, you directly modify the source code in the `suckless-configs/` directory. This includes editing `config.def.h` and applying patches.
-   **Nix's Role (Reproducible Build):** After your preparation, `nixos-rebuild switch` executes the Nix derivation, compiling your customized code in a pure environment.

## Key Configuration Details

### Daemon-less GTK Theming

This configuration achieves consistent GTK theming without background services by:
1.  Installing core GTK libraries system-wide.
2.  Using Home Manager to write `settings.ini` files.
3.  Setting the `GTK_THEME` environment variable to forcefully override application themes.

### Declarative Emacs Configuration

The Emacs setup is a core part of this workflow, designed to be powerful yet minimal.
-   **Installation:** `emacs-nox` is installed via `home.packages` for a terminal-only experience. All required language servers (`clojure-lsp`, etc.) are also installed here, making them available system-wide.
-   **Configuration:** The configuration is written in modular Emacs Lisp files within `dotfiles/emacs/`. Home Manager links this directory to `~/.config/emacs`.
-   **Keybindings:** A modern, non-modal keybinding scheme is implemented using a `Space` leader key, with the `which-key` package providing discoverable pop-up menus. This makes the powerful features of Emacs accessible without memorizing obscure key chords.
-   **Clojure Focus:** The environment is tailored for interactive Clojure development using CIDER, the de-facto standard REPL-driven development tool.

### System Hardening and Optimization

This configuration includes several non-default settings for improved security and performance, including kernel parameter hardening and automatic Nix store optimization.

## Installation and Replication

To use this configuration on your own machine:

1.  **Prerequisites**: You need a working NixOS installation with Flakes enabled.
2.  **Clone the Repository**: `git clone https://github.com/bengtfrost/NixOS-with-Suckless.git`
3.  **Adapt for Your Hardware**: **CRITICAL:** Replace `hardware-configuration.nix` with the one from your machine.
4.  **Adapt for Your User**: Update usernames in `flake.nix`, `configuration.nix`, and `users/blfnix.nix`.
5.  **Build the System**: `sudo nixos-rebuild switch --flake .#nixos`

## Daily Workflow

-   **To change a `dwm` keybinding:** Edit `suckless-configs/dwm/config.def.h`, then run `sudo nixos-rebuild switch --flake .`.
-   **To change Emacs behavior:** Edit the relevant `.el` file in `dotfiles/emacs/`, then restart Emacs.
-   **To add a new application:** Add it to `home.packages` in `users/blfnix.nix`, then run `home-manager switch --flake .`.
-   **Clojure Development:** Open a `.clj` file in Emacs, run `M-x cider-jack-in` to start the interactive REPL, and evaluate code directly from your editor.

---
*This configuration is provided under the MIT License.*
