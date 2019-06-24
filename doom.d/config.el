;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here

;; Change the font!
(setq doom-font (font-spec :family "Source Code Pro" :size 18))

;; avy
;; Make avy target all windows
(setq avy-all-windows t)

;; projectile
;; Look for projects in these folders
;; TODO add .projectile files to all projects in ~/learn
(setq  projectile-project-search-path '("~/dev" "~/learn" "~/sandbox"))

;; company
;; Disable suggestions in org-mode
(setq company-global-modes '(not org-mode))

;; which-key
;; Make which-key display sooner. I should make it slower as I learn more, but
;; having it be quick helps discoverability in the beginning.
(setq which-key-idle-delay 0.1)

;; filetype specifics
(setq js-indent-level 2)

;; minor mode hooks
;; I think this is the way to enable the prettier minor mode for the files I
;; want to auto-format
(add-hook 'json-mode-hook 'prettier-js-mode)
;; (add-hook 'javascript-mode-hook 'prettier-js-mode)
(add-hook 'js2-mode-hook 'prettier-js-mode)
;; (add-hook 'js-jsx-mode-hook 'prettier-js-mode)
(add-hook 'yaml-mode-hook 'prettier-js-mode)
