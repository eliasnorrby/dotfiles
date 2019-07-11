;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here

;; Change the font!
(setq doom-font (font-spec :family "Source Code Pro" :size 12))

;; keybindings
;; use the map! macro to bind things,
;; and unmap! to unmap.
;; example: (unmap! 'motion "g s l")
(map! :map 'evilem-map
      "l" #'avy-goto-line
      "c" #'avy-goto-char-timer
      (:prefix "d"
        "l" #'avy-kill-whole-line
        "r" #'avy-kill-region))

;; avy
;; Make avy target all windows
(setq avy-all-windows t)

;; projectile
;; Look for projects in these folders
;; TODO add .projectile files to all projects in ~/learn
(setq projectile-project-search-path '("~/dev" "~/learn" "~/sandbox"))

;; org
;; Disable company suggestions in org-mode
;; (setq company-global-modes '(not org-mode))

;; Hide inline code markers
(setq org-hide-emphasis-markers t)

;; Set completion time on DONE toggle
(setq org-log-done 'time)

;; which-key
;; Make which-key display sooner. I should make it slower as I learn more, but
;; having it be quick helps discoverability in the beginning.
(setq which-key-idle-delay 0.4)

;; filetype specifics
(setq js-indent-level 2)

;; web mode
;; (add-to-list 'auto-mode-alist )

;; minor mode hooks
;; I think this is the way to enable the prettier minor mode for the files I
;; want to auto-format
(add-hook 'json-mode-hook 'prettier-js-mode)
;; (add-hook 'javascript-mode-hook 'prettier-js-mode)
(add-hook 'js2-mode-hook 'prettier-js-mode)
;; (add-hook 'js-jsx-mode-hook 'prettier-js-mode)
(add-hook 'yaml-mode-hook 'prettier-js-mode)
(add-hook 'mhtml-mode-hook 'prettier-js-mode)
