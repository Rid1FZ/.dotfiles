;;; company-mode.el --- Config For `company-mode' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package company
  :ensure t

  :hook
  ((prog-mode . global-company-mode)
   (text-mode . global-company-mode))

  :bind
  (:map company-active-map
	("TAB" . company-select-next)
	("<tab>" . company-select-next)
	("RET" . (lambda ()
		   (interactive)
		   (if (company-explicit-action-p)
		       (company-complete)
		     (newline-and-indent))))
	("<return>" . (lambda ()
			(interactive)
			(if (company-explicit-action-p)
			    (company-complete)
			  (newline-and-indent)))))
  
  :init
  (setq company-selection-default nil)

  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)
  (company-insertion-triggers nil)
  (company-format-margin-function #'company-vscode-dark-icons-margin)
  (company-frontends
	'(company-pseudo-tooltip-frontend
	  company-echo-metadata-frontend))
  (company-backends
   '((company-bbdb :with company-yasnippet)
     (company-semantic :with company-yasnippet)
     (company-cmake :with company-yasnippet)
     (company-capf :with company-yasnippet )
     (company-clang :with company-yasnippet)
     (company-files :with company-yasnippet)
     (company-dabbrev-code :with company-yasnippet)
     (company-gtags :with company-yasnippet)
     (company-etags :with company-yasnippet)
     (company-keywords :with company-yasnippet)
     (company-dabbrev :with company-yasnippet)))

  :config
  (yas-global-mode 1))


;;; company-mode.el ends here
