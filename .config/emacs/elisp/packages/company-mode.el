;;; company-mode.el --- Config For `company-mode' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)

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
	  company-echo-metadata-frontend)))


;;; company-mode.el ends here
