;; ~/Utveckling/nixos-suckless/dotfiles/emacs/lisp/ui.el

;; -*- lexical-binding: t; -*-
;; This file is optimized for a terminal-only (emacs-nox) experience.

;; --- Terminal UI Tweaks ---
(menu-bar-mode -1)                   ; Disable top menu bar.
(setq-default cursor-type 'bar)      ; Use a bar-shaped cursor
(setq inhibit-startup-message t)    ; Disable the splash screen
(global-display-line-numbers-mode 1) ; Show line numbers
(column-number-mode 1)             ; Show the current column number

;; --- Indentation Settings ---
(setq-default indent-tabs-mode nil) ; Use spaces instead of tab characters.
(setq-default tab-width 1)          ; Set the visual width of a tab to 1 spaces.

;; --- Theme Customization ---
;; Set custom theme variables BEFORE loading the theme.
;; This changes the background color of the active modeline for the doom-one theme.
;; (setq doom-one-modeline-bg "darkgrey")
;; You can also use a more specific hex code for a nicer grey, e.g., "#333333"

;; --- Theme ---
;; Doom themes have excellent support for 256-color terminals. The appearance
;; will be mapped to your terminal emulator's color palette.
(use-package doom-themes
  :ensure t
  :config
  ;; Load the theme that you are customizing.
  (load-theme 'doom-molokai t))

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
