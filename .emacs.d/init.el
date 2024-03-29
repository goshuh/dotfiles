; version
;(unless (version< emacs-version "25.3")
;  (progn ...))

; gui related
(setq
  column-number-mode            t
  debug-on-error                nil
  frame-title-format           "emacs %b"
  inhibit-startup-message       t
  line-number-mode              t
  mouse-wheel-progressive-speed nil
  ring-bell-function           'ignore)

(setq-default
  truncate-lines                t)

(if (display-graphic-p)
    (progn
      ; font settings, generated by eh-font
      (set-face-attribute 'default nil :font
        (font-spec
          :name   "-*-Fira Code-normal-normal-normal-*-*-*-*-*-m-0-iso10646-1"
          :weight 'normal
          :slant  'normal
          :size   '10.1))
      (tool-bar-mode -1))
   ; terminal
   (setq base16-theme-256-color-source "colors"))

(blink-cursor-mode   -1)
(global-hl-line-mode  1)
(global-linum-mode    1)
(show-paren-mode      1)
(auto-image-file-mode t)

(if (window-system)
    (set-frame-size (selected-frame) 180 45)
  (require 'mouse)
  (xterm-mouse-mode t)
  (setq
    visible-cursor nil
    mouse-sel-mode t))

; editing related
(cua-mode             1)
(electric-pair-mode   1)

(fset 'yes-or-no-p   'y-or-n-p)

(setq
  auto-save-default          nil
  create-lockfiles           nil
  cua-keep-region-after-copy t
  default-major-mode        'text-mode
  default-tab-width          4
  kill-whole-line            t
  make-backup-files          nil
  mouse-yank-at-point        t
  show-paren-style          'parenthesis
  track-eol                  t)

(setq-default
  indent-tabs-mode           nil
  tab-width                  4)

; package related
(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("org"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/org/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/local")

(load-theme 'base16-default-dark t)

; elscreen too old
;(autoload 'elscreen "elscreen" nil t)
;(setq elscreen-display-tab nil)
;(elscreen-start)

(autoload 'evil "evil" nil t)

(evil-mode 1)

(autoload 'helm "helm" nil t)
(setq
  helm-mode-fuzzy-match                 t
  helm-etags-fuzzy-match                t
  helm-locate-fuzzy-match               t
  helm-apropos-fuzzy-match              t
  helm-recentf-fuzzy-match              t
  helm-buffers-fuzzy-matching           t
  helm-completion-in-region-fuzzy-match t
  ; https://github.com/emacs-helm/helm/issues/1000
  tramp-ssh-controlmaster-options       nil)

(helm-mode            1)
(helm-autoresize-mode 1)

(autoload 'company "company" nil t)
(setq
  company-idle-delay            0.0
  company-minimum-prefix-length 3)

(global-company-mode  1)

(autoload 'yasnippet "yasnippet" nil t)
(setq yas-verbosity 0)
;      yas-snippet-dirs '("~/.emacs.d/elpa/yasnippet-20170624.803/snippets"))

(yas-global-mode      1)

(autoload 'org-mode "org" nil t)
(add-to-list 'auto-mode-alist '("\\.org$"   . org-mode))

(autoload 'verilog-mode "verilog-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.s?vp?$" . verilog-mode))

(autoload 'paredit-mode "paredit" nil t)
(add-hook 'scheme-mode-hook
  (lambda ()
    (paredit-mode 1)))

; misc function
(defun move-text (start end n)
  (let ((col (current-column)))
    (if (not (use-region-p))
      (progn
        (beginning-of-line)
        (setq start (point))
        (next-line)
        (setq end (point))))
    (let ((text (delete-and-extract-region start end)))
      (forward-line n)
      (insert text)
      (forward-line -1)
      (forward-char col))))

(defun move-text-up (&optional start end n)
  (interactive "r\np")
  (move-text start end (if (null n) -1 (- n))))

(defun move-text-down (&optional start end n)
  (interactive "r\np")
  (move-text start end (if (null n) 1 n)))

(defun split-horizontal (fn &optional wc)
  (interactive
   (find-file-read-args "Find file at right: "
     (confirm-nonexistent-file-or-buffer)))
  (setq split-height-threshold 1024)
  (setq split-width-threshold 0)
  (find-file-other-window fn wc))

(defun split-vertical (fn &optional wc)
  (interactive
   (find-file-read-args "Find file at below: "
     (confirm-nonexistent-file-or-buffer)))
  (setq split-height-threshold 0)
  (setq split-width-threshold 1024)
  (find-file-other-window fn wc))

(defun clear-whole-line ()
  (interactive)
  (kill-whole-line)
  (newline-and-indent)
  (forward-line -1))

(defun copy-whole-line ()
  (interactive)
  (kill-ring-save (line-beginning-position) (line-beginning-position 1)))

(defun middle-new-line ()
  (interactive)
  (move-end-of-line 1)
  (newline-and-indent))

(defun toggle-comment ()
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(defun align-all (start end re)
  (interactive "r\nsAlign-all regexp: ")
  (align-regexp start end (concat "\\(\\s-*\\)" re) 1 0 t))

(defun define-keys (keymap key def &rest bindings)
  (while key
    (define-key keymap (kbd key) def)
    (setq key (pop bindings)
          def (pop bindings))))

(defun evil-enter-leader (map)
  (let* ((key (read-event nil nil 0.5))
         (fun (lookup-key map (vector key))))
    (if fun
        (call-interactively fun)
      (if (evil-insert-state-p)
          (progn
            (insert-char 59)
            (if (characterp key) (insert-char key)))))))

(defvar evil-normal-leader-local-map (make-sparse-keymap))
(use-local-map evil-normal-leader-local-map)

(defvar evil-insert-leader-local-map (make-sparse-keymap))
(use-local-map evil-insert-leader-local-map)

(defvar evil-visual-leader-local-map (make-sparse-keymap))
(use-local-map evil-visual-leader-local-map)

(global-unset-key (kbd "C-SPC"))
(global-unset-key (kbd "M-c"))
(global-unset-key (kbd "M-d"))
(global-unset-key (kbd "M-y"))
(global-unset-key (kbd "M-p"))

; keybindings
(define-keys global-map
  "<f5>"      'save-buffer
  "S-<f5>"    'write-file
  "C-<up>"    'move-text-up
  "C-<down>"  'move-text-down
  "C-<left>"  'previous-buffer
  "C-<right>" 'next-buffer
; "C-<prior>" 'elscreen-previous
; "C-<next>"  'elscreen-next
  "C-q"       'evil-visual-block
  "M-x"       'helm-M-x
  "M-y"       'helm-show-kill-ring
  "M-f"       'helm-mini)

(define-keys evil-normal-state-map
  "SPC"       'evil-insert
  ";"         (lambda ()
                (interactive)
                (evil-enter-leader evil-normal-leader-local-map)))

(define-keys evil-normal-leader-local-map
  "<tab>"     'other-window
  "c"         'toggle-comment
  "-"         'split-vertical
  "\\"        'split-horizontal
  "="         'ediff-buffers
; "t"         'elscreen-create
; "k"         'elscreen-kill
  "l"         'switch-to-buffer
  "w"         'kill-buffer-and-window
  "q"         'delete-window
  "v"         'mark-whole-buffer
  "<return>"  'helm-find-files)

(define-keys evil-insert-state-map
  "M-c"       'clear-whole-line
  "M-d"       'kill-whole-line
  "M-y"       'copy-whole-line
  "M-p"       'yank
  "M-u"       'undo-tree-undo
  "M-r"       'undo-tree-redo
  "M-,"       'evil-search-previous
  "M-."       'evil-search-next
  ";"         (lambda ()
                (interactive)
                (evil-enter-leader evil-insert-leader-local-map)))

(define-keys evil-insert-leader-local-map
  ";"         'evil-normal-state
  "v"         'evil-visual-state
  "<tab>"     'other-window
  "c"         'toggle-comment
  "'"         'forward-sexp
  "["         'forward-char
  "]"         'middle-new-line
  "\\"        'move-end-of-line
  "<return>"  (lambda ()
                (interactive)
                (insert-char 10)
                (newline-and-indent)))

(define-keys evil-visual-state-map
  ";"         (lambda ()
                (interactive)
                (evil-enter-leader evil-visual-leader-local-map)))

(define-keys evil-visual-leader-local-map
  "c"         'comment-or-uncomment-region
  "e"         'align-regexp
  "E"         'align-all)

; lang related
(defun c-stuff-init ()
  (setq
    indent-tabs-mode              t
    tab-width                     4
    c-basic-offset                4
    c-default-style              "linux"
    cscope-do-not-update-database t)

  (require 'irony)
  (require 'xcscope)
  (irony-mode 1)
  (cscope-setup)

  (define-keys evil-insert-leader-local-map
    "<return>" (lambda ()
                 (interactive)
                 (move-end-of-line 1)
                 (insert-char 59)
                 (c-context-line-break)))

  ; cscope related
  (define-keys evil-normal-leader-local-map
    "o" 'cscope-set-initial-directory
    "s" 'cscope-find-this-symbol
    "d" 'cscope-find-global-definition
    "a" 'cscope-find-assignments-to-this-symbol
    "f" 'cscope-find-called-functions
    "F" 'cscope-find-functions-calling-this-function
    "i" 'cscope-find-files-including-file)

  (c-toggle-auto-newline 1)
  (irony-cdb-autosetup-compile-options)
  (company-irony-setup-begin-commands)
  (add-to-list 'company-backends 'company-irony))

(add-hook 'c-mode-common-hook 'c-stuff-init)
