;;; fontify-patch.el --- Fontify patches             -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Waqar Hameed

;; Author: Waqar Hameed <whame91@gmail.com>
;; Keywords: gnus, mu4e, diff, patch
;; URL: https://github.com/whame/fontify-patch

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package can be used to fontify a buffer (or string) that contains a
;; patch diff. For example, to fontify mail buffers with gnus:
;;
;; (add-hook 'gnus-part-display-hook 'fontify-patch-buffer)
;;
;; This will scan the buffer for a diff (according to `diff-mode') and fontify
;; it. Similarily, it can be used on strings, e.g. to insert fontified patches
;; in a buffer:
;;
;; (insert (fontify-patch-text patch-text))

;;; Code:

(require 'diff-mode)
(require 'font-lock)
(require 'message)

(defun fontify-patch--beginning-of-patch ()
  "Beginning of diff in patch."
  (when (re-search-forward diff-file-header-re nil t)
    (re-search-backward "^---$" nil t)
    (point)))

(defun fontify-patch--end-of-patch ()
  "End of diff in patch."
  (diff-end-of-file)
  (point))

;;;###autoload
(defun fontify-patch-buffer ()
  "Fontify a buffer that contains a patch diff.

Buffer will be fontified according to `diff-mode' (i.e.
`diff-font-lock-defaults')."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((beg (fontify-patch--beginning-of-patch))
          (end (fontify-patch--end-of-patch))
          (old-end (point-max))
          (old-font-lock-defaults font-lock-defaults))
      (when (and beg end)
        (while (/= end old-end)
          (setq old-end end)
          (setq end (fontify-patch--end-of-patch)))
        ;; If this is a patch with a mail signature (e.g. obtained with `git
        ;; format-patch`), we don't want to interpret the signature delimiter
        ;; "-- \n" as a deleted-line diff. There is of course a possibility that
        ;; the diff do contain a deleted "- \n" line, but a signature delimiter
        ;; is probably more common (since `--signature` is default for `git
        ;; format-patch`).
        (when (re-search-backward message-signature-separator beg t)
          (setq end (point)))
        (setq-local font-lock-defaults diff-font-lock-defaults)
        (unwind-protect
            (font-lock-fontify-region beg end nil)
          (setq-local font-lock-defaults old-font-lock-defaults))))))

;;;###autoload
(defun fontify-patch-text (text)
  "Fontify TEXT that contains a patch diff.

TEXT will be fontified according to `diff-mode' (i.e.
`diff-font-lock-defaults')."
  (setq text (with-temp-buffer
               (insert text)
               (fontify-patch-buffer)
               (buffer-string)))
  (let ((pos 0)
        (next))
    (while (setq next (next-single-property-change pos 'face text))
      (put-text-property pos next 'font-lock-face
                         (get-text-property pos 'face text) text)
      (setq pos next))
    (add-text-properties 0 (length text) '(fontified t) text)
    text))

(provide 'fontify-patch)
;;; fontify-patch.el ends here
