;;; swiper.el --- Config For `swiper' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package swiper
  :ensure t

  :after
  (ivy ivy-rich)

  :hook
  (ivy-mode . swiper-mode))

;;; swiper.el ends here
