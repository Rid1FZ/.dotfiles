;;; key-chord.el --- Config For `key-chord' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package key-chord
  :ensure t

  :custom
  (key-chord-two-keys-delay 0.2)

  :config
  (key-chord-mode 1))

;;; key-chord.el ends here
