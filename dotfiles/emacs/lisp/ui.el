;; ~/Utveckling/nixos-suckless/dotfiles/emacs/lisp/ui.el

;; -*- lexical-binding: t; -*-
;; This file is optimized for a terminal-only (emacs-nox) experience.

;; --- Terminal UI Tweaks ---
(menu-bar-mode -1)                   ; Disable top menu bar.
(setq-default cursor-type 'bar)      ; Use a bar-shaped cursor
(setq inhibit-startup-message t)    ; Disable the splash screen
(global-display-line-numbers-mode 1) ; Show line numbers
(column-number-mode 1)             ; Show the current column number

;; --- Theme ---
;; Doom themes have excellent support for 256-color terminals. The appearance
;; will be mapped to your terminal emulator's color palette.
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-monokai-pro t))

;; --- Minibuffer/Completion Enhancements ---
;; These packages work perfectly in the terminal.
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :after vertico
  :init
  (marginalia-mode))

(use-package savehist
  :init
  (savehist-mode))
