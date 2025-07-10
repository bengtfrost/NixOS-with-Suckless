;; -*- lexical-binding: t; -*-

;; New, smarter tab command.
(defun blfnix/smart-tab ()
  "A smart tab command that completes, indents, or inserts spaces.
If company-mode completion is active, complete.
If the point is at the beginning of the line, indent the line.
Otherwise, insert spaces according to 'tab-width'."
  (interactive)
  (cond
   ;; Condition 1: Company completion is active. Use the internal function for this.
   ((and (bound-and-true-p company-mode) (company--active-p))
    (company-complete-common-or-cycle))

   ;; Condition 2: Point is at the beginning of the line (only whitespace before it).
   ((looking-back "^[ \t]*" nil)
    (indent-for-tab-command))

   ;; Condition 3: Otherwise, just insert a 'dumb' tab (which is spaces).
   (t
    (insert-tab))))

(provide 'custom)
