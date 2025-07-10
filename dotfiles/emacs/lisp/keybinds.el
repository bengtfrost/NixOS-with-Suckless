;; -*- lexical-binding: t; -*-

;; --- Which-key for command discovery ---
;; Shows available keybindings in a popup after a short delay.
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; --- General.el for easy keybinding configuration ---
;; We define keys inside :config, which runs after the package is loaded.
(use-package general
  :ensure t
  :config
  (general-define-key
   :keymaps 'global
   "SPC" '(nil :which-key "Leader")

   "SPC SPC" '(execute-extended-command :which-key "M-x (Command Palette)")

   "SPC f"   '(:ignore t :which-key "File")
   "SPC f f" '(find-file :which-key "Find File") ; Use built-in find-file
   "SPC f s" '(save-buffer :which-key "Save Buffer")

   ;; We will define the project leader key in langs.el after projectile is loaded.
   "SPC p"   '(:ignore t :which-key "Project (see langs.el)")

   "SPC b"   '(:ignore t :which-key "Buffer")
   "SPC b b" '(switch-to-buffer :which-key "Switch Buffer")
   "SPC b k" '(kill-current-buffer :which-key "Kill Current Buffer")

   "SPC w"   '(:ignore t :which-key "Window")
   "SPC w /" '(split-window-right :which-key "Split Right")
   "SPC w -" '(split-window-below :which-key "Split Below")
   "SPC w d" '(delete-window :which-key "Delete Window")
   "SPC w o" '(delete-other-windows :which-key "Delete Other Windows")))
