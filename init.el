;;; -*- lexical-binding: t -*-

;;; ---------------------------------------------------------------------------
;;; 1. Bootstrap
;;; ---------------------------------------------------------------------------

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; ---------------------------------------------------------------------------
;;; 2. Core
;;; ---------------------------------------------------------------------------

(setq inhibit-startup-message t)

(tool-bar-mode -1)
(menu-bar-mode -1)
(tooltip-mode -1)

(set-fringe-mode 10)

(column-number-mode 1)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

(savehist-mode 1)
(save-place-mode 1)

(pixel-scroll-precision-mode 1)

(use-package dired
  :ensure nil
  :after evil-collection
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom
  (dired-listing-switches "-agho --group-directories-first")
  ;; Скрывать скрытые файлы (замена dired-hide-dotfiles)
  (dired-omit-files (rx (seq bol ".")))
  :hook
  (dired-mode . dired-omit-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(setq dired-kill-when-opening-new-dired-buffer t)

(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle))
  :config
  (setq dired-subtree-use-backgrounds nil))

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :ensure t
  :config
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

;;; ---------------------------------------------------------------------------
;;; 3. Editing/Evil
;;; ---------------------------------------------------------------------------

(use-package undo-fu)

(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :init
  (setq evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init))

(with-eval-after-load 'evil-collection
  (with-eval-after-load 'dired
    (evil-define-key 'normal dired-mode-map
      "H" 'dired-omit-mode)))

;;; ---------------------------------------------------------------------------
;;; Projectile
;;; ---------------------------------------------------------------------------

(use-package projectile
  :init
  (projectile-mode 1)
  :custom
  (projectile-project-search-path '("~/Projects/" "~/.config/"))
  (projectile-completion-system 'default)
  (projectile-sort-order 'recently-active))

;;; ---------------------------------------------------------------------------
;;; Magit
;;; ---------------------------------------------------------------------------

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package git-gutter
  :init (global-git-gutter-mode 1)
  :custom (git-gutter:update-interval 2))

;;; ---------------------------------------------------------------------------
;;; Magit
;;; ---------------------------------------------------------------------------

(use-package lsp-mode
  :ensure t
  :hook
  ;; Запускать lsp-mode для этих режимов (замени на свои языки)
  (python-mode . lsp)
  (python-ts-mode . lsp)
  (go-mode . lsp)
  (go-ts-mode . lsp)
  (rust-mode . lsp)
  (rust-ts-mode . lsp)
  :custom
  ;; Префикс для команд lsp-mode. У тебя лидер SPC, так что можно C-c l
  (lsp-keymap-prefix "C-c l")
  ;; Включать which-key для lsp команд (у тебя он уже есть)
  (lsp-enable-which-key-integration t)
  ;; Не спрашивать подтверждения для некоторых действий
  (lsp-auto-guess-root t) ; автоматически определять корень проекта
  :config
  ;; Если хочешь использовать Consult для поиска символов в проекте
  (with-eval-after-load 'consult
    (define-key lsp-mode-map [remap xref-find-apropos] #'consult-lsp-symbols)))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-enable t) ; показывать документацию при наведении
  (lsp-ui-sideline-enable t)) ; показывать ошибки/инфо в строке

(use-package consult-lsp
  :ensure t
  :after (consult lsp-mode))

;;; ---------------------------------------------------------------------------
;;; 4. Keybindings
;;; ---------------------------------------------------------------------------

(use-package which-key
  :init (which-key-mode 1)
  :custom
  (which-key-idle-delay 0.4)
  (which-key-idle-secondary-delay 0.1))

(use-package general
  :after evil
  :config
  (general-evil-setup t)

  (general-create-definer my/leader-keys
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  (my/leader-keys
    ;; Файлы и буферы
    "f f" '(find-file :which-key "find file")
    "b b" '(consult-buffer :which-key "switch buffer")

    ;; Поиск
    "/"   '(consult-ripgrep :which-key "search project")
    "s l" '(consult-line :which-key "search line in buffer")
    "s f" '(consult-find :which-key "search files")

    "p" '(:keymap projectile-command-map :which-key "projectile")

    "g g" '(magit-status :which-key "magit status")

    "d d" '(dired :which-key "open dired")

    ;; Помощь
    "h k" '(describe-key :which-key "describe key")
    "h f" '(describe-function :which-key "describe function")
    "h v" '(describe-variable :which-key "describe variable")

    ;; Выход
    "q q" '(save-buffers-kill-emacs :which-key "quit emacs")))

;;; ---------------------------------------------------------------------------
;;; 5. Completion
;;; ---------------------------------------------------------------------------

(use-package vertico
  :init (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic)))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("M-g g" . consult-goto-line)))

;;; ---------------------------------------------------------------------------
;;; 6. UI/Visuals
;;; ---------------------------------------------------------------------------

(use-package doom-themes
  :config
  (load-theme 'doom-gruvbox t))

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 130)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;;; ---------------------------------------------------------------------------
;;; 7. Tools
;;; ---------------------------------------------------------------------------

;;; ---------------------------------------------------------------------------
;;; 8. Programming
;;; ---------------------------------------------------------------------------

;;; ---------------------------------------------------------------------------
;;; 9. Custom file
;;; ---------------------------------------------------------------------------

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))


