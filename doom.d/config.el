;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here

;; :weight

;; VALUE specifies the weight of the font to use.  It must be one of the
;; symbols ultra-bold, extra-bold, bold, semi-bold, normal,
;; semi-light, light, extra-light, ultra-light.

;; Change the font!
;; (setq doom-font (font-spec :family "Source Code Pro" :size 14))
;; (setq doom-font (font-spec :family "mononoki Nerd Font" :size 14))
;; (setq doom-font (font-spec :family "Iosevka Nerd Font" :size 14))
(setq doom-font (font-spec :family "Iosevka Nerd Font" :weight 'light :size 14))
;; (setq doom-font (font-spec :family "MesloLGMDZ Nerd Font" :size 14))
;; (setq doom-font (font-spec :family "Fira Code Retina" :size 14))

;; Set the theme
(setq doom-theme 'doom-palenight)

;; line numbers
;; TODO I need to find a way to only enable this in code buffers
;; (setq-default display-line-numbers 'relative)

;; keybindings
;; use the map! macro to bind things,
;; and unmap! to unmap.
;; example: (unmap! 'motion "g s l")
(map! :map 'evilem-map
      "l" #'avy-goto-line
      "c" #'avy-goto-char-timer
      "i" #'avy-goto-char-in-line
      (:prefix "d"
        "l" #'avy-kill-whole-line
        "r" #'avy-kill-region))
(map! :map 'ivy-minibuffer-map
      "S-SPC" #'ivy-immediate-done)

;; avy
;; Make avy target all windows
(setq avy-all-windows t)

;; projectile
;; Look for projects in these folders
(setq projectile-project-search-path '("~/dev/" "~/learn/" "~/sandbox/"))

;; org
;; Disable company suggestions in org-mode
;; (setq company-global-modes '(not org-mode))

;; Hide inline code markers
(setq org-hide-emphasis-markers t)

;; Set completion time on DONE toggle
(setq org-log-done 'time)

;; Try to avoid accidental edits
(setq-default org-catch-invisible-edits 'error)
(setq-default org-ctrl-k-protect-subtree 'error)

;; org keybindings
(map! :map org-mode-map
      :localleader
      ;; "m" #'org-toggle-narrow-to-subtree
      "SPC" #'org-narrow-to-subtree
      "m" #'widen)

(add-hook 'org-mode-hook (lambda () (setq display-line-numbers nil)))

;; which-key
;; Make which-key display sooner. I should make it slower as I learn more, but
;; having it be quick helps discoverability in the beginning.
;; (setq which-key-idle-delay 0.4)

;; web mode
;; (add-to-list 'auto-mode-alist )

;; minor mode hooks
;; I think this is the way to enable the prettier minor mode for the files I
;; want to auto-format
;; (add-hook 'json-mode-hook 'prettier-js-mode)
;; (add-hook 'js2-mode-hook 'prettier-js-mode)
;; (add-hook 'yaml-mode-hook 'prettier-js-mode)
;; (add-hook 'mhtml-mode-hook 'prettier-js-mode)

;; (add-hook 'web-mode-hook 'prettier-js-mode)
;; (add-hook 'javascript-mode-hook 'prettier-js-mode)
;; (add-hook 'js-jsx-mode-hook 'prettier-js-mode)

;; ;; stolen from https://github.com/ar1a/dotfiles/blob/master/emacs/.doom.d/config.el
;; (after! emmet-mode
;;   ;; this is already done in emmet :config but it doesn't seem to get set on my
;;   ;; machine, so let's do it again
;;   (map! :map emmet-mode-keymap
;;         :v [tab] #'emmet-wrap-with-markup
;;         ;; :i [tab] #'+web/indent-or-yas-or-emmet-expand
;;         :i "C-e" #'emmet-expand-line))

;;; Bug fixing
;; Henrik told me to try this snippet to fix broken session reestores
;; after straight was merged into develop. I don't know how long I need to keep
;; it here.
; (after! persp-mode
;   (remove-hook 'persp-filter-save-buffers-functions #'buffer-live-p)

;   (defun +workspaces-dead-buffer-p (buf)
;     (not (buffer-live-p buf)))
;   (add-hook 'persp-filter-save-buffers-functions #'+workspaces-dead-buffer-p))

;;; Optimizations
;; Somebody said scrolling was slow and henrik suggested this:
;; (setq fast-but-imprecise-scrolling nil)
;; (setq inhibit-compacting-font-caches nil)

;; Also, this could help with flickering
;; (add-to-list 'default-frame-alist '(inhibit-double-buffering . t))
