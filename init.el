;;; init.el --- My Emacs init configuration

;;; Commentary:

;; This is Tennix's Emacs configuration.
;; The latest version can be found at https://github.com/tennix/emacs.d

(global-set-key (kbd "C-x ?") 'help-command)
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "C-d") 'delete-char)
(global-unset-key (kbd "C-x C-o"))

;;; Code:
(setq package-archives
      '( ;; ("gnu" . "http://elpa.gnu.org/packages/")
	("gnu" . "http://elpa.zilongshanren.com/gnu/")
	 ;; ("marmalade" . "http://marmalade-repo.org/packages/")
	("marmalade" . "http://elpa.zilongshanren.com/marmalade/")
	 ;; ("melpa" . "http://melpa.milkbox.net/packages/")
	("melpa" . "http://elpa.zilongshanren.com/melpa/")))

(setq package-enable-at-startup nil)
(package-initialize)

(elscreen-start)

;;; Emacs auto generated customization file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;;; some good default settings
(fset 'yes-or-no-p 'y-or-n-p)
(setq-default ookmark-default-file (expand-file-name ".bookmarks.el" user-emacs-directory)
	      case-fold-search t
	      column-number-mode t
	      make-backup-files nil
	      tooltip-delay 1.5
	      inhibit-startup-message t
	      initial-scratch-message ""
	      ediff-split-window-function 'split-window-horizontally
	      ediff-window-setup-function 'ediff-setup-windows-plain)

; (setq-default line-spacing 0.2)

(blink-cursor-mode 0)

(setq tab-width 8)
(setq-default indent-tabs-mode t)


;;; prettify symbol mode,
;;; Eg: lambda will be replaced by Greek letter lambda
; (global-prettify-symbols-mode)

;;; builtin parenthesis editing
(electric-pair-mode) ;; replaced with smartparens-mode
(show-paren-mode t)  ;; faster than show-smartparens-mode

;;; subword mode for prog-mode CamelCase and snake_case word
;(add-to-list-hook 'prog-mode-hook 'subword-mode)

;;; automatically revert files
(setq-default global-auto-revert-non-file-buffers t
	      auto-revert-verbose nil)
(global-auto-revert-mode)

;;; recent files
(setq-default recentf-max-saved-items 500
	      recentf-exclude '("^/tmp/"
				"^/ssh:"
				"\\.emacs\\.d/elpa/"))
(recentf-mode 1)

(defun eh-ivy-return-recentf-index (dir)
  (when (and (boundp 'recentf-list)
             recentf-list)
    (let ((files-list
           (cl-subseq recentf-list
                      0 (min (- (length recentf-list) 1) 20)))
          (index 0))
      (while files-list
        (if (string-match-p dir (car files-list))
            (setq files-list nil)
          (setq index (+ index 1))
          (setq files-list (cdr files-list))))
      index)))

(defun eh-ivy-sort-file-function (x y)
  (let* ((x (concat ivy--directory x))
         (y (concat ivy--directory y))
         (x-mtime (nth 5 (file-attributes x)))
         (y-mtime (nth 5 (file-attributes y))))
    (if (file-directory-p x)
        (if (file-directory-p y)
            (let ((x-recentf-index (eh-ivy-return-recentf-index x))
                  (y-recentf-index (eh-ivy-return-recentf-index y)))
              (if (and x-recentf-index y-recentf-index)
                  ;; Directories is sorted by `recentf-list' index
                  (< x-recentf-index y-recentf-index)
                (string< x y)))
          t)
      (if (file-directory-p y)
          nil
        ;; Files is sorted by mtime
        (time-less-p y-mtime x-mtime)))))

;;; uniquify buffer names
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse
      uniquify-separator " • "
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*")

;;; disable menu-bar, tool-bar, scroll-bar
(toggle-scroll-bar -1)
(tool-bar-mode -1)
(fringe-mode '(16 . 0))

;;; copy current buffer filename to clipboard
(defun copy-filename-to-clipboard ()
  "Copy current buffer file name to clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
		      default-directory
		    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

;;; kill current line when no region is active
; (defadvice kill-region (before slick-cut activate compile)
;   "When called interactively with no active region, kill current line."
;   (interactive
;    (if mark-active (list (region-beginning) (region-end))
;      (list (line-beginning-position)
; 	   (line-beginning-position 2)))))

;;; I prefer cmd key for meta
(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)

;;; replace buffer-menu with ibuffer
(global-set-key (kbd "C-x C-b") 'ibuffer)

;;; use-package and diminish
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(unless (package-installed-p 'diminish)
  (package-install 'diminish))

(require 'use-package)
(setq use-package-always-ensure t)

;; Powerline
(use-package powerline
  :config
  (setq powerline-height 16)
  (setq powerline-raw " ")
  (setq ns-use-srgb-colorspace t)
  (powerline-raw mode-line-mule-info nil 'l)
  (setq powerline-default-separator nil)
  (powerline-default-theme))

;;; Read environment variable from shell config
(use-package exec-path-from-shell
  :when (memq window-system '(mac ns))
  :config
  (dolist (var '("SSH_AUTH_SOCK"
		 "SSH_AGENT_PID"
		 "GPG_AGENT_INFO"
		 "LANG"
		 "LC_CTYPE"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

;;; Solarized color theme
(use-package solarized-theme
  :when window-system
  :config
  (setq solarized-use-variable-pitch nil
	solarized-scale-org-headlines nil
	solarized-high-contrast-mode-line t)
  (setq solarized-distinct-fringe-background nil)
  (setq solarized-use-variable-pitch nil)
  (setq solarized-high-contrast-mode-line t)
  (setq solarized-use-less-bold t)
  (setq solarized-emphasize-indicators nil)
  (setq solarized-scale-org-headlines nil)
  ; (setq solarized-height-minus-1 1)
  ; (setq solarized-height-plus-1 1)
  ; (setq solarized-height-plus-2 1)
  ; (setq solarized-height-plus-3 1)
  ; (setq solarized-height-plus-4 1)
  (load-theme 'solarized-light t))
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (let ((mode (if (display-graphic-p frame) 'light 'dark)))
              (set-frame-parameter frame 'background-mode mode)
              (set-terminal-parameter frame 'background-mode mode))
            (enable-theme 'solarized)))

;; smart-mode-line: for more compact mode line
(use-package smart-mode-line
  :when window-system
  :config
  (sml/setup))

;;; auto-compile: Automatically compile Emacs Lisp libraries
(use-package auto-compile
  :init (setq load-prefer-newer t)
  :config (auto-compile-on-load-mode))

;; external linum mode, better performance than builtin linum mode
 ; (use-package nlinum
 ;   :config (global-nlinum-mode))

;; guide-key: hint for shortcut keys
(use-package guide-key
  :diminish guide-key-mode
  :config
  (setq guide-key/guide-key-sequence
	'("C-x r" "C-x 4" "C-c"))
  (guide-key-mode 1))

;;; rainbow-delimiters: colorful delimiters
(use-package rainbow-delimiters
  :init (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

;;; dealing with trailing whitespace
(defun trailing-whitespace-mode ()
  "Show whitespaces and unused lines."
  (progn
    (setq show-trailing-whitespace t)
    (setq indicate-unused-lines t)))
(add-hook 'prog-mode-hook 'trailing-whitespace-mode)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; Highlight-indent-guides: similar to sublime-text
; (use-package highlight-indent-guides
;   :init (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
;   :config
;     (setq highlight-indent-guides-method 'character)
;     (setq highlight-indent-guides-character ?\|)
;     (setq highlight-indent-guides-auto-enabled nil)
;     (setq highlight-indent-guides-auto-character-face-perc 0)
;     (set-face-foreground 'highlight-indent-guides-character-face "gray"))

;;; Highlight symbol
; (use-package highlight-symbol
;   :diminish highlight-symbol-mode
;   :bind (("C-x M-p" . highlight-symbol-prev)
; 	 ("C-x M-n" . highlight-symbol-next)
; 	 ("C-x M-r" . highlight-symbol-query-replace))
;   :init
;   (add-hook 'prog-mode-hook 'highlight-symbol-mode)
;   (add-hook 'prog-mode-hook 'highlight-symbol-nav-mode))

;;; smartparens: strcutural parenthesis editing
(use-package smartparens
  :init
  (add-hook 'prog-mode-hook #'smartparens-mode)
  (add-hook 'emacs-lisp-mode-hook #'smartparens-strict-mode)
  :config
  (require 'smartparens-config))

;;; origami: code folding
; (use-package origami
;   :diminish origami
;   :bind (:map origami-mode-map
; 	      ("C-c f" . origami-recursively-toggle-node)
; 	      ("C-c F" . origami-toggle-all-nodes))
;   :init (add-hook 'prog-mode-hook 'origami-mode))

;;; undo-tree: [C-x u] opens undo tree
(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (setq undo-tree-visualizer-timestamps t
	undo-tree-visualizer-diff t)
  (global-undo-tree-mode))

;;; switch-window: switch other window with a number
(use-package switch-window
  :bind (("C-x o" . switch-window)))

;;; save cursor place when close file
(if (version< emacs-version "25.0")
    (use-package saveplace :init (setq-default save-place t))
  (save-place-mode 1))

;;; Elscreen: tabbed window session manager modeled after GNU screen
(use-package elscreen
  :if window-system
  :config
  (progn
    (set-face-attribute 'elscreen-tab-background-face nil :inherit 'default :background nil)
    (setq-default elscreen-tab-display-control nil)
    (setq-default elscreen-tab-display-kill-screen nil)
    (elscreen-set-prefix-key "\C-q")
    (elscreen-start)))

(use-package elscreen-persist
  :init
  (defcustom desktop-data-elscreen nil nil
    :type 'list
    :group 'desktop)
  :if window-system
  :config
  (setq desktop-files-not-to-save ""
	desktop-restore-frames nil)
  (defun desktop-prepare-data-elscreen! ()
    (setq desktop-data-elscreen (elscreen-persist-get-data)))
  (defun desktop-evaluate-data-elscreen! ()
    (when desktop-data-elscreen
      (elscreen-persist-set-data desktop-data-elscreen)))
  (add-hook 'desktop-after-read-hook 'desktop-evaluate-data-elscreen!)
  (add-hook 'desktop-save-hook 'desktop-prepare-data-elscreen!)
  (add-hook 'desktop-globals-to-save 'desktop-data-elscreen)
  (desktop-save-mode 1))

;;; Projectile: Project navigation and management library for Emacs
(use-package projectile
  :config
  (define-key projectile-mode-map (kbd "C-x C-o") 'projectile-find-file)
  (setq-default projectile-mode-line/com
  		'(:eval (if (file-remote-p default-directory)
  			    " Proj"
  			  (format " Proj[%s]" (projectile-project-name)))))
  (projectile-global-mode))

;;; yasnippet: A template system for Emacs
(use-package yasnippet
  :init
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-reload-all))

;;; Company mode: modular in-buffer completion framework for Emacs
(use-package company
  :diminish (company-mode "CMP")
  :init
  (add-hook 'prog-mode-hook 'company-mode)
  :config
  (setq company-idle-delay 0.2)
  (setq company-tooltip-align-annotations t)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous))

;;; smex used with counsel
(use-package smex
  :defer t
  :config
  (setq smex-save-file (expand-file-name ".smex-items" user-emacs-directory))
  (smex-initialize))

;;; Ivy, swiper, counsel, avy
(use-package ivy
  :diminish ivy-mode
  :bind (:map ivy-minibuffer-map
	      ;; ido style directory navigation
	      ("C-j" . ivy-immediate-done)
	      ("RET" . ivy-alt-done))
  :config
  (setq ivy-use-virtual-buffers t
	ivy-virtual-abbreviate 'full
	ivy-extra-directories nil
	ivy-count-format "(%d/%d) "
	projectile-completion-system 'ivy
	ivy-initial-inputs-alist '((counsel-M-x . "^")
				   (man . "^")
				   (woman . "^")))
  ;; sort files by mtime
  (add-to-list 'ivy-sort-functions-alist
	       '(read-file-name-internal . eh-ivy-sort-file-function))
  (ivy-mode 1))

(use-package counsel
  :diminish counsel-mode
  :config
  (setq counsel-mode-override-describe-bindings t)
  (counsel-mode))

(use-package swiper
  :bind (:map ivy-mode-map
	      ("C-s" . swiper)))

(use-package avy
  :bind (("C-;" . avy-goto-char-2)))

;; Flycheck for syntax check
 (use-package flycheck
   :defer t
   :init
   (add-hook 'prog-mode-hook 'flycheck-mode)
   :config
   (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled)
 	flycheck-idle-change-delay 0.5
 	flycheck-display-errors-function #'flycheck-display-error-messages-unless-error-list))

;; builtin flyspell for spell checking
;; (use-package flyspell
;;   :ensure t
;;   :diminish (flyspell-mode "FlyS")
;;   :init
;;   (add-hook 'prog-mode-hook 'flyspell-prog-mode)
;;   (add-hook 'text-mode-hook 'flyspell-prog-mode))

;;; Text search with grep, ag
(use-package ag
  :defer t
  :config
  (setq ag-highlight-search t)
  (add-hook 'ag-mode-hook 'wgrep-ag-setup))
(use-package wgrep
  :config
  (setq grep-highlight-matches t
	grep-scroll-output t))
(use-package wgrep-ag :defer t)

;;; Git
; (use-package git-gutter
;   :diminish git-gutter-mode
;   :bind (("C-x p" . git-gutter:previous-hunk)
; 	 ("C-x n" . git-gutter:next-hunk))
;   :config
;   (git-gutter:linum-setup)
;   (global-git-gutter-mode t))

(use-package magit
  :bind (("C-x g" . magit-status)))

;;; org mode
; (use-package org-bullets :defer t)
; (use-package org
;   :defer t
;   :init
;   (setq org-hide-emphasis-markers t)
;   (add-hook 'org-mode-hook 'org-bullets-mode)
;   (font-lock-add-keywords 'org-mode
; 			  '(("^ +\\([-*]\\) "
; 			     (0 (prog1 ()
; 				  (compose-region
; 				   (match-beginning 1)
; 				   (match-end 1) "•")))))))

;;; Syntax highlighting for common configuration file formats ;;;
(use-package dockerfile-mode :defer t)
(use-package json-mode :defer t)
(use-package yaml-mode
  :defer t
  :config
  (add-hook 'yaml-mode-hook 'trailing-whitespace-mode))
(use-package toml-mode :defer t)
(use-package protobuf-mode :defer t)
(use-package hcl-mode :defer t)
(use-package markdown-mode
  :defer t
  :mode ("\\.\\(md\\|markdown\\)\\'" . markdown-mode))
(use-package gh-md :defer t)

;;; irfc: Downloading and viewing RFC
(use-package irfc
  :defer t
  :config
  (setq irfc-directory "~/rfcs"
	irfc-assoc-mode t))

;;; Rust
(use-package rust-mode
  :mode ("\\.rs\\'" . rust-mode)
  :config
  (add-hook 'rust-mode-hook #'racer-mode)
  (defun rust-save-compile-and-run ()
    (interactive)
    (save-buffer)
    (if (locate-dominating-file (buffer-file-name) "Cargo.toml")
        (compile "cargo run")
      (compile
       (format "rustc %s && %s"
	       (buffer-file-name)
	       (file-name-sans-extension (buffer-file-name))))))
  (add-hook 'rust-mode-hook
	    (lambda () (define-key rust-mode-map (kbd "M-g M-r") 'rust-save-compile-and-run))))
(use-package racer
  :diminish racer-mode
  :bind (:map rust-mode-map
	      ("M-g M-d" . racer-find-definition)
	      ("M-g M-t" . pop-tag-mark)
	      ("TAB" . company-indent-or-complete-common))
  :init
  (if (eq system-type 'darwin)
      (exec-path-from-shell-copy-env "RUST_SRC_PATH"))
  :config
  (add-hook 'racer-mode-hook #'eldoc-mode))
(use-package flycheck-rust
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;;; Python
; (use-package elpy
;   :defer t
;   :init (add-hook 'python-mode-hook 'elpy))

;;; Haskell
(use-package haskell-mode
  :bind (:map haskell-mode-map
	      ("C-c C-l" . haskell-process-load-or-reload)
	      ("C-c C-t" . haskell-process-do-type)
	      ("C-c C-i" . haskell-process-do-info)
	      ("C-c C-c" . haskell-process-cabal-build)
	      ("C-c c" . haskell-process-cabal)
	      ("M-." . haskell-mode-jump-to-def))
  :config
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
  (add-hook 'haskell-mode-hook 'intero-mode))
(use-package intero :defer t)

;;; Lisp
; (use-package slime-company :defer t)
; (use-package slime
;   :defer t
;   :config
;   (setq slime-contribs '(slime-fancy slime-company))
;   (when (executable-find "sbcl")
;     (add-to-list 'slime-lisp-implementations
; 		 '(sbcl ("sbcl") :coding-system utf-8-unix)))
;   (when (executable-find "lisp")
;     (add-to-list 'slime-lisp-implementations
; 		 '(cmucl ("lisp") :coding-system iso-latin-1-unix)))
;   (when (executable-find "ccl")
;     (add-to-list 'slime-lisp-implementations
; 		 '(ccl ("ccl") :coding-system utf-8-unix))))

;;; Go
(use-package go-eldoc :defer t)
(use-package company-go :defer t)
(use-package go-mode
  :defer t
  :init
  (if (eq system-type 'darwin)
      (exec-path-from-shell-copy-env "GOPATH"))
  :config
  (setq gofmt-command "goimports")
  (setq godef-command "godef")
  (add-hook 'go-mode-hook (lambda ()
			    (set (make-local-variable 'company-backends)
				 '(company-go))
			    (set (make-local-variable 'compile-command)
				 "go build -v && go test -v && go vet && golint")
			    (go-eldoc-setup)))
  (add-hook 'before-save-hook 'gofmt-before-save)
  (evil-define-key 'normal go-mode-map
    "gd" 'godef-jump))

;;; Web development
(use-package restclient :defer t)
(use-package emmet-mode
  :defer t
  :init
  (add-hook 'css-mode-hook 'emmet-mode)
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'html-mode-hook 'emmet-mode))
(use-package js2-mode :mode ("\\.js\\'" . js2-mode))
(use-package tide
  :defer t
  :config
  (setq tide-format-options '(:insertSpaceAfterFunctionKeywordForAnonymousFunctions t :placeOpenBraceOnNewLineForFunctions nil))
  (defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (eldoc-mode 1)
    (add-hook 'before-save-hook 'tide-format-before-save))
  (add-hook 'typescript-mode-hook 'setup-tide-mode))
(use-package web-mode
  :mode (("\\.html?\\'" . web-mode)
	 ("\\.php\\'" . web-mode)
	 ("\\.erb\\'" . web-mode)
	 ("\\.djhtml\\'" . web-mode))
  :config
  (setq web-mode-enable-auto-pairing nil
	web-mode-enable-current-element-highlight t
	web-mode-enable-css-colorization t
	web-mode-enable-current-element-highlight t)
  (add-hook 'web-mode-hook 'emmet-mode))
(use-package typescript-mode
  :defer t
  :config (add-hook 'typescript-mode-hook #'tide-mode))

(setq x-underline-at-descent-line t)

;;; finally, evilized
(use-package evil)
(evil-mode 1)
(provide 'init-evil)

(use-package evil-commentary)
(evil-commentary-mode)

(require 'bash-completion)
(bash-completion-setup)

(with-eval-after-load "esh-opt"
  (require 'virtualenvwrapper)
  (venv-initialize-eshell)
  (autoload 'epe-theme-lambda "eshell-prompt-extras")
  (setq eshell-highlight-prompt nil
        eshell-prompt-function 'epe-theme-lambda))

(eval-after-load 'eshell
    '(require 'eshell-z nil t))

(global-fasd-mode 1)
(put 'erase-buffer 'disabled nil)
