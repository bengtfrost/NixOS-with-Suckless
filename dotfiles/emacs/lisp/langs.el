;; ... (at the end of langs.el) ...

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
