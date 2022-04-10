;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Ryan Wu"
      user-mail-address "921581278@qq.com")
(setq rime-show-candidate 'posframe)
(setq rime-translate-keybindings   '("C-j" "C-k" "C-l" "C-h" "<left>" "<right>" "<up>" "<down>" "<prior>" "<next>" "<delete>"))
(setq rime-disable-predicates
      '(rime-predicate-evil-mode-p
        rime-predicate-after-alphabet-char-p
        rime-predicate-prog-in-code-p))
;; 针对 rime posframe 最后一项丢失的bug
(defun +rime--posframe-display-content-a (args)
"给 `rime--posframe-display-content' 传入的字符串加一个全角空
格，以解决 `posframe' 偶尔吃字的问题。"
(cl-destructuring-bind (content) args
(let ((newresult (if (string-blank-p content)
                        content
                        (concat content "　"))))
(list newresult))))

(if (fboundp 'rime--posframe-display-content)
(advice-add 'rime--posframe-display-content
                :filter-args
                #'+rime--posframe-display-content-a)
(error "Function `rime--posframe-display-content' is not available."))

(set-language-environment "utf-8")
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(setq line-move-visual nil)
(set-fontset-font "fontset-default" 'chinese-gbk "微软雅黑")

(setq face-font-rescale-alist '(("宋体" . 1.2)
                ("微软雅黑" . 1.1)
                ))

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)



;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq lsp-gopls-staticcheck t)
(setq lsp-eldoc-render-all t)
(setq lsp-gopls-complete-unimported t)
(add-hook 'prog-mode-hook #'wucuo-start)
(add-hook 'text-mode-hook #'wucuo-start)
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred))

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Optional - provides fancier overlays.
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; Company mode is a standard completion package that works well with lsp-mode.
(use-package company
  :ensure t
  :config
  ;; Optionally enable completion-as-you-type behavior.
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1))

;; Optional - provides snippet support.
(use-package yasnippet
  :ensure t
  :commands yas-minor-mode
  :hook (go-mode . yas-minor-mode))

(use-package! telega
  :commands (telega)
  :defer t
  :config
  (set-fontset-font t 'unicode (font-spec :family "Symbola") nil 'append)
  (setq telega-symbol-unread "🄌"))

;; evil-nerd-commenter
(use-package evil-nerd-commenter
  :init (evilnc-default-hotkeys))

;; theme
(setq doom-theme 'doom-one-light)
(doom-themes-neotree-config)
(setq doom-themes-neotree-file-icons t)

;; bdword 翻译函数
(setq appid "20220217001085792")
(setq salt "1435660288")
(setq key_bd "wDZMfhzrxlAqUrZuI4JL")
(require 'json)
(setq conbime_sign (concat appid "apple" salt key_bd))
(setq sign (md5 conbime_sign nil nil 'binary))

(defun bdword ()
  (interactive)
  (setq qword (buffer-substring-no-properties (region-beginning) (region-end)))
  (goto-char (region-end))
  (setq conbime_sign (concat appid qword salt key_bd))
  (setq sign (md5 conbime_sign nil nil 'binary))
  (setq url (concat "http://api.fanyi.baidu.com/api/trans/vip/translate?q=" qword "&from=en&to=zh&appid=" appid "&salt=" salt "&sign=" sign))
  (with-temp-buffer
    (url-insert-file-contents
     url)
    (let ((json-false :false))
      (setq res (json-read))
      (setq body (alist-get 'trans_result res))
      (setq meaning (aref body 0))
      (setq chi (alist-get 'dst meaning))
      (message "%s" chi)
      )))
