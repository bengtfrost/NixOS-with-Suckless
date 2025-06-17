# Declarative Suckless Desktop on NixOS

<div align="center">

![NixOS Logo](https://img.shields.io/badge/NixOS-25.05-5277C3.svg?style=for-the-badge&logo=NixOS&logoColor=white)
![Suckless DWM](https://img.shields.io/badge/suckless-dwm-blue.svg?style=for-the-badge)
![Home Manager](https://img.shields.io/badge/Home--Manager-25.05-informational.svg?style=for-the-badge)
![Nix Flakes](https://img.shields.io/badge/flakes-enabled-green.svg?style=for-the-badge)

</div>

This repository contains a complete, declarative configuration for a minimal and powerful desktop environment on NixOS. It fuses the minimalist philosophy of the [suckless.org](https://suckless.org/) toolset with the reproducible and robust system management of NixOS, using Flakes and Home Manager.

The core principle is to treat the **manually prepared Suckless source code** as the definitive input for the system build. All patching and `config.def.h` customization is done by you, directly on the source files, *before* invoking the Nix build. Nix then takes these pre-customized sources and builds them within a pure environment, resulting in a fully reproducible, custom-tailored desktop environment.

## Screenshots

<p align="center">
  <img src="./assets/nix-suckless-desktop.png" width="48%" alt="Clean dwm desktop with slstatus bar"/>
  <img src="./assets/nix-suckless-apps.png" width="48%" alt="Desktop with st, helix, and a file manager"/>
</p>

## Table of Contents

- [Core Philosophy](#core-philosophy)
- [Features](#features)
- [System Structure](#system-structure)
- [The Declarative Suckless Build Process](#the-declarative-suckless-build-process)
- [Key Configuration Details](#key-configuration-details)
  - [Solving GTK Theming and GSettings](#solving-gtk-theming-and-gsettings)
  - [System Hardening and Optimization](#system-hardening-and-optimization)
  - [The `xinitrc` Session](#the-xinitrc-session)
- [Installation and Replication](#installation-and-replication)
- [Daily Workflow](#daily-workflow)

## Core Philosophy

This setup is born from two ideals:

1.  **Suckless:** Software that is simple, minimal, and does one thing well. The configuration is done by patching and editing the C source code directly.
2.  **NixOS:** A Linux distribution where the entire system configuration—from the kernel to packages to dotfiles—is defined in a set of declarative files. Builds are reproducible and atomic.

By combining them, we achieve the ultimate goal: a system where even our custom-patched window manager and terminal are just another part of a single, version-controlled, reproducible configuration.

## Features

-   **Fully Declarative:** The entire system is managed by the Nix Flake in this repository.
-   **Custom Suckless Stack:** `dwm`, `st`, `dmenu`, and `slstatus` are all built from user-customized local source code.
-   **Robust GTK/GSettings Theming:** A clean, declarative solution ensures GTK2, GTK3, and GTK4 applications are themed correctly without daemons or complex wrappers.
-   **Home Manager:** Manages all user-level configuration, including dotfiles, packages, services, and environment variables.
-   **Minimalist Session Management:** Uses a declarative `~/.xinitrc` file to launch the `dwm` session via `startx`, which is triggered automatically on console login.
-   **System Hardening:** Includes security-focused kernel parameters and a hardened Avahi configuration.
-   **Nix Store Optimization:** Configured for automatic garbage collection and store optimization.
-   **Modern Shell:** Zsh with auto-suggestions, syntax highlighting, and useful aliases, with `PATH` managed declaratively by Home Manager.

## System Structure

The repository is organized to clearly separate concerns:

```
.
├── flake.nix                 # The central entry point for the entire system build.
├── configuration.nix         # System-level NixOS settings (kernel, packages, etc.).
├── hardware-configuration.nix  # Hardware-specific settings (auto-generated).
├── users/
│   └── blfnix.nix            # User-level configuration via Home Manager.
├── suckless-configs/         # Raw source code for the suckless tools. This is where you edit config.def.h!
│   ├── ...
├── dotfiles/                 # Static configuration files (e.g., for helix).
│   └── ...
└── assets/                   # Screenshots for the README.
    ├── nix-suckless-apps.png
    └── nix-suckless-desktop.png
```

-   **`flake.nix`**: Defines the project's inputs (nixpkgs, home-manager) and orchestrates the build.
-   **`configuration.nix`**: Defines the machine, including system-wide packages, fonts, and security settings.
-   **`users/blfnix.nix`**: Defines the user environment, containing the Suckless build logic and all user-level configuration.
-   **`suckless-configs/`**: The heart of the customization. It holds the source code for each suckless tool, which you modify directly.

## The Declarative Suckless Build Process

The magic happens in `users/blfnix.nix` within the `buildCustomSucklessTool` function. This function creates a Nix derivation that treats your manually prepared source code as its input. It is crucial to understand the division of labor:

-   **Your Role (Manual Preparation):** Before building, you directly modify the source code in the `suckless-configs/` directory. This includes editing `config.def.h` and applying any necessary patches with standard tools.
-   **Nix's Role (Reproducible Build):** After your preparation is complete, `nixos-rebuild switch` executes the Nix derivation, compiling your customized code in a pure environment.

> **Note on the `patches/` directories:** These exist only as a convenient place to store patch files. Patching must be done by you on the source code before a build.

## Key Configuration Details

### Solving GTK Theming and GSettings

Getting modern GTK applications to respect themes in a minimal, non-GNOME environment is a significant challenge. This configuration solves it cleanly with a three-part strategy:

1.  **System-Level Packages:** All core GTK libraries (`gtk3`, `gtk4`), the `gsettings` tool (`glib`), and schema providers (`gsettings-desktop-schemas`) are installed in `configuration.nix`. This provides a stable, system-wide foundation and ensures a correctly constructed base environment.
2.  **Declarative `settings.ini` Files:** The desired theme and font settings are written to `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini` by Home Manager. This is the "source of truth" for the theme.
3.  **Session-Start Schema Compilation:** The `.xinitrc` file executes `glib-compile-schemas` when the graphical session starts. This crucial step reads all available schemas (from the system-installed packages) and creates a fast-loading binary cache in the user's home directory. This cache is what GTK applications actually use, resolving all discovery issues.

This combination avoids complex wrappers, environment variable hacks, and unnecessary daemons like `dconf`.

### System Hardening and Optimization

This configuration includes several non-default settings for improved security and performance:
-   **Kernel Parameters:** `slab_nomerge`, `init_on_alloc=1`, and `page_alloc.shuffle=1` are enabled for memory allocation hardening.
-   **Nix Store Optimization:** `nix.settings.auto-optimise-store = true;` is enabled to reduce storage space by hard-linking identical files.
-   **Hardened Services:** The Avahi daemon is configured with publishing features explicitly disabled for a reduced attack surface.

### The `xinitrc` Session

The declarative `.xinitrc` is the heart of the user session. Beyond launching `dwm` and its companion apps, it now includes:
-   The `glib-compile-schemas` command to ensure GTK theming works.
-   A switch from `dbus-launch` to `systemd-cat` for executing `dwm`. This provides better integration with the systemd journal, making logs for the window manager accessible via `journalctl --identifier=dwm`.

## Installation and Replication

To use this configuration on your own machine:

1.  **Prerequisites**: You need a working NixOS installation with Flakes enabled.
2.  **Clone the Repository**: `git clone https://github.com/bengtfrost/NixOS-with-Suckless.git`
3.  **Adapt for Your Hardware**: **CRITICAL:** Replace `hardware-configuration.nix` with the one from your machine.
4.  **Adapt for Your User**: Update usernames in `flake.nix`, `configuration.nix`, and `users/blfnix.nix`.
5.  **Build the System**: `sudo nixos-rebuild switch --flake .#nixos`

## Daily Workflow

-   **To change a `dwm` keybinding:** Edit `suckless-configs/dwm/config.def.h` and run `nix-update-system`.
-   **To change your terminal's appearance:** Edit `suckless-configs/st/config.def.h` and run `nix-update-system`.
-   **To add a new application:** Add it to `home.packages` in `users/blfnix.nix` and run `nix-update-system`.

---
*This configuration is provided under the MIT License.*
