;;; which-key.el --- Config For `which-key' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package which-key
  :ensure nil
  :diminish which-key-mode

  :init
  (which-key-mode)

  :custom
  (which-key-idle-delay 0.3))

;;; which-key.el ends here
