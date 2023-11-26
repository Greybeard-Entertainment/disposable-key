;;; disposable.el --- Disposable key bindings that can be remapped at will using completing read.  -*- lexical-binding: t; -*-

;; Copyright: Aleksandr Petrosyan
;; Author: Aleksandr Petrosyan <TODO>
;; keywords: binding
;; Version: 0.0.3

;;; Blurb

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;;; Code:

(defvar disposable-key-mode-map (make-sparse-keymap nil)
  "The mode map that is used in the disposable-key-mode.

While it is never loaded directly, it is useful to know which
functions were defined.")

(defvar disposable-key-rebind nil
  "If t, override the next disposable key with something else.")

(defvar undefined-func-placeholder nil
  "The placeholder for the function that used to be undefined.")

;; TODO: This is probably the same as disposable-key-mode, but this
;; might not work as smoothly.
(defvar undefined-overridden nil
  "Whether the function undefined is overridden.")

(defun disposable-key-force-rebind ()
  "Force rebinding the next disposable key.

This function is nothing more than changing the variable
`disposable-key-rebind' to true.  The reason it exists is to
provide a simple named binding that can be included in the
documentation to the package."
  (interactive)
  (setq disposable-key-rebind t))


(defun toggle-override-undefined ()
  "Toggle the overriding of the `undefined' function."
  (if undefined-overridden
	  (progn
		(fset 'undefined undefined-func-placeholder)
		(setq undefined-overridden nil))
	(setq undefined-func-placeholder (symbol-function 'undefined))
	(fset 'undefined (symbol-function 'diposable-key-bind))
	(setq undefined-overridden t)))

;;;###autoload
(defun disposable-key-bind ()
  "Bind current disposable key.

You do not need this function if you use `disposable-key-mode'.

This function should be used to bind to keys that are not defined
yet, and you want to be able to define quickly, when you need to
use them."
  (interactive)
  (let ((key (this-command-keys)))
	(let ((definition (keymap-lookup disposable-key-mode-map (key-description key))))
	  (if (or disposable-key-rebind (not definition))
		  ;; Because this has a side effect, defer it and don't use a `let*'
		  (let ((function-name (completing-read (format "Bind %s to: " (key-description key)) obarray 'commandp)))
			(keymap-set disposable-key-mode-map (key-description key) (intern function-name))
			(setq disposable-key-rebind nil))
		(call-interactively definition)))))

;;;###autoload
(define-minor-mode disposable-key-mode
  "Disposable keybindings mode.

This mode is the more aggresive of the two ways to use this package.

If you enable this mode, the built-in function which gets called
when you press an undefined key (`undefined') is overridden with
a way to bind the key to something, and uses the
`completing-read' interface to query for the name of the
function.

I prefer this way, but I can see why most people would prefer
that the disposable bindings be reserved for some keys, but not
others."
  :init-value nil
  :lighter " ĸ"
  :keymap disposable-key-mode-map
  (toggle-override-undefined))

;;;###autoload
(defun turn-on-disposable-key-mode ()
  "Turn on `disposable-key-mode'."
  (interactive)
  (disposable-key-mode +1))

;;;###autoload
(defun turn-off-disposable-key-mode ()
  "Turn off `disposable-key-mode'."
  (interactive)
  (disposable-key-mode -1))

;;;###autoload
(define-globalized-minor-mode disposable-key-global-mode
  disposable-key-mode
  turn-on-disposable-key-mode)

(provide 'disposable-key)
;;; disposable-key.el ends here

;; Local Variables:
;; jinx-local-words: "el"
;; End:
