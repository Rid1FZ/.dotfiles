;;; anaconda-mode.el --- Config For `anaconda-mode' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package anaconda-mode
  :ensure t

  :hook
  (python-mode . (lambda ()
                   (anaconda-mode)
                   (anaconda-eldoc-mode)))
  (python-ts-mode . (lambda ()
                      (anaconda-mode)
                      (anaconda-eldoc-mode))))

;;; anaconda-mode.el ends here
