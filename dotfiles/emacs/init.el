;; -*- lexical-binding: t; -*-

;; --- Package Management ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;; --- Load Custom Configuration Modules ---
(let ((lisp-dir (expand-file-name "lisp" user-emacs-directory)))
  (load-file (concat lisp-dir "/ui.el"))
  (load-file (concat lisp-dir "/custom.el"))
  (load-file (concat lisp-dir "/keybinds.el"))
  (load-file (concat lisp-dir "/clojure.el"))
  (load-file (concat lisp-dir "/langs.el")))

(put 'upcase-region 'disabled nil)
