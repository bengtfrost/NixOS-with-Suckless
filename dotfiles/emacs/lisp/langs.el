;; -*- lexical-binding: t; -*-

;; --- LSP (Language Server Protocol) Integration ---
;; lsp-mode is the core client for all language servers provided by NixOS.
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :init
  ;; Sets the prefix for LSP-related commands (e.g., C-c l a for code actions)
  (setq lsp-keymap-prefix "C-c l")
  :config
  ;; Automatically format the buffer on save, using the detected LSP formatter.
  (add-hook 'before-save-hook #'lsp-format-buffer))

;; --- LSP UI for a prettier experience ---
;; Provides pop-up documentation, diagnostics on the side, etc.
(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode))

;; --- Autocompletion Engine ---
(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.2)
  ;; Make Tab complete if a suggestion is available, otherwise indent the line.
  ;; Replace the old binding with our new custom function.
  (define-key company-mode-map (kbd "<tab>") #'blfnix/smart-tab)
  (define-key company-mode-map (kbd "TAB") #'blfnix/smart-tab))

;; --- Treesitter for better syntax highlighting ---
;; Emacs 29+ has this built-in. This ensures it's configured and modes are installed.
(use-package treesit-auto
  :ensure t
  :config
  (global-treesit-auto-mode))

;; --- Language-specific setup ---
;; lsp-mode will automatically detect and start most servers from your PATH.
;; We just need to ensure the major modes are installed and hooks are set up.

;; Nix
(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")

;; Rust
(use-package rust-mode
  :ensure t
  :config
  (add-hook 'rust-mode-hook #'lsp-deferred))


;; Python
(use-package python-mode
  :ensure t
  :config
  (add-hook 'python-mode-hook #'lsp-deferred))

;; C/C++ (uses built-in modes)
(add-hook 'c-mode-hook #'lsp-deferred)
(add-hook 'c++-mode-hook #'lsp-deferred)

;; Typescript/JS
(use-package typescript-mode
  :ensure t
  :mode ("\\.ts\\'" "\\.tsx\\'")
  :config
  (add-hook 'typescript-mode-hook #'lsp-deferred))

;; Web (for JS, JSON, etc. - provides basic syntax)
(use-package web-mode
  :ensure t
  :mode ("\\.js\\'" "\\.jsx\\'" "\\.json\\'"))

;; Zig
(use-package zig-mode
  :ensure t
  :hook (zig-mode . lsp-deferred))

;; --- Project Management ---
;; Projectile helps manage project-specific tasks.
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  ;; Define project-specific leader keys here, after projectile is loaded.
  (general-define-key
   :keymaps 'global
   "SPC p f" '(projectile-find-file :which-key "Find File in Project")
   "SPC p p" '(projectile-switch-project :which-key "Switch Project")
   "SPC p s" '(projectile-save-project-buffers :which-key "Save Project Buffers"))

  ;; The default Emacs-style binding is C-c p
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))
