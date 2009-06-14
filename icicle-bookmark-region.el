;;; icicle-bookmark-region.el --- 
;; 
;; Author: 
;; Maintainer: 
;; 
;; Created: ven. juin 12 15:43:59 2009 (+0200)
;; Version: 
;; URL: 
;; Keywords: 
;; Compatibility: 
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; 
;;; Commentary: 
;; 
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change log:
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:

(defun* icicle-exchange-point-and-mark (&optional arg) ; Bound to `C-x C-x'.
  "`exchange-point-and-mark', `icicle-add-region', or `icicle-select-region'.
With no prefix arg: `exchange-point-and-mark'.
With a numeric prefix arg:`icicle-add-region'.
With a plain `C-u' prefix arg: `icicle-select-region'.

By default, Icicle mode remaps all key sequences that are normally
bound to `exchange-point-and-mark' to
`icicle-exchange-point-and-mark'.  If you do not want this remapping,
then customize option `icicle-top-level-key-bindings'."
  (interactive "P")
  (if arg
      (if (atom arg)
          (call-interactively #'icicle-bookmark-cmd) ;(call-interactively #'icicle-add-region)
          (unless (consp (bookmark-region-alist-only));icicle-region-alist)
            (error "`icicle-region-alist' is empty; try again, with a numeric prefix arg"))
          (call-interactively #'icicle-select-region))
      (call-interactively #'exchange-point-and-mark)))

(icicle-define-command icicle-bookmark  ; Command name
  "Jump to a bookmark.
You can use `S-delete' on any bookmark during completion to delete it.
If `crosshairs.el' is loaded, then the target position is highlighted." ; Doc string
  icicle-bookmark-jump                  ; Function to perform the action
  "Bookmark: " (mapcar #'list (if current-prefix-arg
                                  (bookmark-region-alist-only-names)
                                  (bookmark-all-names))) ; `completing-read' args
  nil t nil (if (boundp 'bookmark-history) 'bookmark-history 'icicle-bookmark-history)
  (and (boundp 'bookmark-current-bookmark) bookmark-current-bookmark)
  nil
  ((completion-ignore-case          bookmark-completion-ignore-case) ; Additional bindings
   (icicle-delete-candidate-object  'bookmark-delete))
  nil (icicle-bookmark-cleanup) (icicle-bookmark-cleanup)) ; First code, undo code, last code

(icicle-define-command icicle-select-region  ; Command name
  "Jump to a bookmark.
You can use `S-delete' on any bookmark during completion to delete it.
If `crosshairs.el' is loaded, then the target position is highlighted." ; Doc string
  icicle-bookmark-jump                  ; Function to perform the action
  "Bookmark: " (mapcar #'list (bookmark-region-alist-only-names)) ; `completing-read' args
  nil t nil (if (boundp 'bookmark-history) 'bookmark-history 'icicle-bookmark-history)
  (and (boundp 'bookmark-current-bookmark) bookmark-current-bookmark)
  nil
  ((completion-ignore-case          bookmark-completion-ignore-case) ; Additional bindings
   (icicle-delete-candidate-object  'bookmark-delete))
  nil (icicle-bookmark-cleanup) (icicle-bookmark-cleanup)) ; First code, undo code, last code

(defun icicle-bookmark-jump (bookmark)
  "Jump to BOOKMARK.
You probably don't want to use this.  Use `icicle-bookmark' instead.
If `crosshairs.el' is loaded, then the target position is highlighted."
  (interactive (list (bookmark-completing-read "Jump to bookmark" bookmark-current-bookmark)))
  (bookmark-jump-other-window bookmark))
  ;(icicle-bookmark-jump-1 bookmark))

(defun icicle-bookmark-cmd (&optional parg) ; Bound to what `bookmark-set' is bound to (`C-x r m').
  "Set bookmark or visit bookmark(s).
With no prefix argument or a plain prefix arg (`C-u'), call
`bookmark-set' to set a bookmark, passing the prefix arg.

With a non-negative numeric prefix argument, set a bookmark at point,
giving it a name that is the buffer name followed by the text starting
at point (after a space).  At most `icicle-bookmark-name-length-max'
characters of buffer text are used for the name.  If the prefix
argument is 0, then do not overwrite any bookmarks that have the same
name.

With a negative prefix argument, call `icicle-bookmark' to visit a
bookmark.

By default, Icicle mode remaps all key sequences that are normally
bound to `bookmark-set' to `icicle-bookmark-cmd'.  If you do not want
this remapping, then customize option
`icicle-top-level-key-bindings'."
  (interactive "P")
  (if (and parg
           (< (prefix-numeric-value parg) 0))
      (icicle-bookmark)
      (let* ((flag-reg (region-active-p))
             (bm-name
              (read-from-minibuffer "Bookmark Name: "
                                    nil nil nil nil
                                    (and parg
                                         (atom parg)
                                         (concat
                                          (buffer-name)
                                          " "
                                          (buffer-substring
                                           (or (and flag-reg (mark)) (point))
                                           (min
                                            (if flag-reg
                                                (point)
                                                (save-excursion
                                                  (end-of-line)
                                                  (point)))
                                            (+ (or (and flag-reg (mark)) (point))
                                               icicle-bookmark-name-length-max))))))))
        
        (when bm-name
          (message "Setting bookmark `%s'" bm-name)
          (sit-for 2))
        (bookmark-set bm-name (and parg
                                   (or (consp parg)
                                       (zerop (prefix-numeric-value parg))))))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; icicle-bookmark-region.el ends here