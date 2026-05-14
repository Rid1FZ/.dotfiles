;;; eglot-python-preset.el --- Config For `eglot-python-preset' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package eglot-python-preset
  :vc (:url "https://github.com/mwolson/eglot-python-preset"
       :main-file "eglot-python-preset.el")
  :after eglot

  :custom
  (eglot-python-preset-lsp-server 'basedpyright)

  :config
  (eglot-python-preset-setup))

;;; eglot-python-preset.el ends here
