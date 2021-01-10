;;; helm-persp-buffer-list.el --- support helm-buffer-list for persp-mode -*- lexical-binding: t -*-

;; Author: Jian Wang <leuven65@gmail.com>
;; URL: https://github.com/leuven65/helm-persp-buffer-list
;; Version: 0.1.0
;; Keywords: Helm, persp-mode, buffer-list

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;

;;; Code:

;; In [[https://github.com/emacs-helm/helm/issues/2311]] (2020/5/30), helm changes to "get rid of
;; ido for listing buffers", so that "persp-set-ido-hooks" won't take any effect on helm, and it
;; needs to adapt the `helm-buffer-list'.
(with-eval-after-load 'helm-buffers
  (with-eval-after-load 'persp-mode
    ;; There is no performance issue.
    (defun my-ordered-persp-buffer-list (&optional persp frame)
      "return the persp buffer list in the order of the frame"
      (let* ((cur-frame (or frame (selected-frame)))
             (current-persp (or persp (get-current-persp cur-frame)))
             (cur-frame-buffers (buffer-list cur-frame)))
        (seq-filter (lambda (b)
                      (memq current-persp (persp--buffer-in-persps b)))
                    cur-frame-buffers))
      )

    (define-advice helm-buffer-list (:around (orig-fun &rest args) my-advice)
      (if (get-current-persp)
          (let* ((my-persp-buffers (my-ordered-persp-buffer-list)))
            ;; dynamically re-define the function`buffer-list'
            (cl-letf (((symbol-function 'buffer-list)
                       (lambda () my-persp-buffers)))
              (apply orig-fun args)))
        (apply orig-fun args)
        )
      )
    ;; (advice-remove 'helm-buffer-list #'helm-buffer-list@my-advice)

    ;; (benchmark 100 '(helm-buffer-list))
    ;; (benchmark 100 '(my-ordered-persp-buffer-list))
    ;; (benchmark 100 '(buffer-list (selected-frame)))

    ))

(provide 'helm-persp-buffer-list)

;;; helm-persp-buffer-list.el ends here
