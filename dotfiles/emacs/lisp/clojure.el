;; -*- lexical-binding: t; -*-

;; --- Clojure Language Support ---
(use-package clojure-mode
  :ensure t
  :mode ("\\.clj\\'" "\\.cljs\\'" "\\.cljc\\'" "\\.edn\\'"))

;; --- CIDER: Clojure Interactive Development Environment that Rocks ---
(use-package cider
  :ensure t
  :after clojure-mode
  :config
  (add-hook 'clojure-mode-hook #'lsp-deferred)
  (setq cider-preferred-build-tool 'clojure-cli)
  (setq cider-repl-display-help-banner nil)
  (setq cider-repl-history-file "~/.cache/emacs/cider-history"))

;; --- Paredit for structured S-expression editing ---
(use-package paredit
  :ensure t
  :hook (clojure-mode . enable-paredit-mode))
