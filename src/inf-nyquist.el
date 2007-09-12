;;; inf-nyquist.el -- Inferior Nyquist Process (Ruby/Scheme/Forth)

;; Copyright (C) 2002--2007 Michael Scholz

;; Author: Michael Scholz <scholz-micha@gmx.de>
;; Created: Wed Nov 27 20:52:54 CET 2002
;; Changed: Sun Mar 25 01:11:47 CET 2007
;; Keywords: processes, nyquist, ruby, scheme, forth

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

;;; Commentary:

;; This file defines a nyquist-in-a-buffer package built on top of
;; comint-mode.  It includes inferior mode for Nyquist-Ruby
;; (inf-nyquist-ruby-mode), Nyquist-Scheme (inf-nyquist-scheme-mode) and Nyquist-Forth
;; (inf-nyquist-forth-mode), furthermore a Nyquist-Ruby mode (nyquist-ruby-mode),
;; a Nyquist-Scheme mode (nyquist-scheme-mode) and a Nyquist-Forth mode
;; (nyquist-forth-mode) for editing source files.  It is tested with
;; Nyquist-Ruby, Nyquist-Scheme and Nyquist-Forth 8.4 and GNU Emacs 22.0.50.

;; Since this mode is built on top of the general command-interpreter-
;; in-a-buffer mode (comint-mode), it shares a common base
;; functionality, and a common set of bindings, with all modes derived
;; from comint mode.  This makes these modes easier to use.  For
;; documentation on the functionality provided by comint-mode, and the
;; hooks available for customizing it, see the file comint.el.

;; A nice feature may be the commands `inf-nyquist-help' and `nyquist-help',
;; which shows the description which Nyquist provides for many functions.
;; With tab-completion in the minibuffer you can scan all functions at
;; a glance.  It should be easy to extent this mode with new commands
;; and key bindings; the example below and the code in this file may
;; show the way.

;; There exist six main modes in this file: the three inferior
;; Nyquist-process-modes (inf-nyquist-ruby-mode, inf-nyquist-lisp-mode and
;; inf-nyquist-forth-mode) and the replacements of ruby-mode
;; (nyquist-ruby-mode), of lisp-mode (nyquist-lisp-mode) and of
;; gforth-mode (nyquist-forth-mode).

;; Variables of the inferior Nyquist-process-modes
;; inf-nyquist-ruby|lisp|forth-mode (defaults):
;;
;; inf-nyquist-lisp-program-name "nyquist-lisp"  Nyquist-Lisp program name
;; inf-nyquist-working-directory   "~/"          where Ruby, Lisp or Forth scripts reside
;; inf-nyquist-lisp-mode-hook    nil           to customize inf-nyquist-lisp-mode
;; inf-nyquist-lisp-quit-hook    nil           to reset nyquist variables before exit
;; inf-nyquist-index-path          "~/"          path to nyquist-xref.c
;; inf-nyquist-prompt              ">"           listener prompt

;; Variables of the editing modes nyquist-ruby|lisp|forth-mode
;; (defaults):
;;
;; nyquist-lisp-mode-hook        nil     	     to customize nyquist-lisp-mode

;; You can start inf-nyquist-ruby-mode interactive either with prefix-key
;; (C-u M-x run-nyquist-ruby)--you will be ask for program name and
;; optional arguments--or direct (M-x run-nyquist-ruby).  In the latter
;; case, variable inf-nyquist-ruby-program-name should be set correctly.
;; The same usage goes for inf-nyquist-lisp-mode and inf-nyquist-forth-mode.

;; Example for your .emacs file:
;;
;; (autoload 'run-nyquist-lisp   "inf-nyquist" "Start inferior Nyquist-Lisp process" t)
;; (autoload 'nyquist-lisp-mode  "inf-nyquist" "Load nyquist-lisp-mode." t)
;;
;; ;; These variables should be set to your needs!
;; (setq inf-nyquist-lisp-program-name "nyquist-gauche -separate")
;; (setq inf-nyquist-lisp-program-name "nyquist-guile -notehook")
;; (setq inf-nyquist-working-directory "~/Nyquist/")
;; (setq inf-nyquist-index-path "~/Nyquist/nyquist/")

;; The hook-variables may be used to set new key bindings and menu
;; entries etc. in your .emacs file, e.g.:
;;
;; (defun nyquist-sounds ()
;;   (interactive)
;;   (inf-nyquist-send-string "(sounds)"))
;;
;; (add-hook 'inf-nyquist-ruby-mode-hook
;; 	  '(lambda ()
;; 	    (define-key (current-local-map) [menu-bar inf-nyquist-ruby-mode foo]
;; 	      '("Sounds" . nyquist-sounds))
;; 	    (define-key (current-local-map) "\C-c\C-t" 'nyquist-sounds)))
;;
;; To edit source code with special key bindings:
;;
;; (add-hook 'nyquist-lisp-mode-hook
;; 	  '(lambda ()
;;	    (define-key (current-local-map) "\C-co" 'nyquist-send-buffer)
;; 	    (define-key (current-local-map) "\C-cr" 'nyquist-send-region)
;; 	    (define-key (current-local-map) "\C-ce" 'nyquist-send-definition)))
;; 
;; You can change the mode in a source file by M-x nyquist-ruby-mode (or
;; nyquist-lisp-mode, nyquist-forth-mode).  To determine automatically which
;; mode to set, you can decide to use special file-extensions.  One
;; may use file-extension `.rbs' for Nyquist-Ruby source files and `.cms'
;; for Nyquist-Lisp.
;;
;; (set-default 'auto-mode-alist
;; 	     (append '(("\\.rbs$" . nyquist-ruby-mode)
;;                     ("\\.cms$" . nyquist-lisp-mode))
;; 		     auto-mode-alist))
;;
;; Or you can use the local mode variable in source files, e.g. by
;; `-*- nyquist-ruby -*-', `-*- nyquist-lisp -*-' or `-*- nyquist-forth -*-' in
;; first line.

;; Key bindings for inf-* and nyquist-*-modes
;; 
;; \e\TAB        nyquist-completion    symbol completion at point
;; C-h m     	 describe-mode	   describe current major mode

;; Key binding of inf-nyquist-ruby|lisp|forth-mode:
;;
;; C-c C-s   	 inf-nyquist-run-nyquist   (Nyquist-Ruby|Lisp|Forth from a dead Nyquist process buffer)
;; M-C-l 	 inf-nyquist-load      load script in current working directory
;; C-c C-f   	 inf-nyquist-file      open view-files-dialog of Nyquist
;; M-C-p 	 inf-nyquist-play      play current sound file
;; C-c C-t 	 inf-nyquist-stop      stop playing all sound files
;; C-c C-i   	 inf-nyquist-help      help on Nyquist-function (nyquist-help)
;; C-u C-c C-i   inf-nyquist-help-html help on Nyquist-function (html)
;; C-c C-q   	 inf-nyquist-quit      send exit to Nyquist process
;; C-c C-k   	 inf-nyquist-kill      kill Nyquist process and buffer

;; Key bindings of nyquist-ruby|lisp|forth-mode editing source
;; files:
;;
;; C-c C-s   	 nyquist-run-nyquist
;; M-C-x     	 nyquist-send-definition
;; C-x C-e   	 nyquist-send-last-sexp
;; C-c M-e   	 nyquist-send-definition
;; C-c C-e   	 nyquist-send-definition-and-go
;; C-c M-r   	 nyquist-send-region
;; C-c C-r   	 nyquist-send-region-and-go
;; C-c M-o   	 nyquist-send-buffer
;; C-c C-o   	 nyquist-send-buffer-and-go
;; C-c M-b   	 nyquist-send-block          (Ruby only)
;; C-c C-b   	 nyquist-send-block-and-go   (Ruby only)
;; C-c C-z   	 nyquist-switch-to-nyquist
;; C-c C-l   	 nyquist-load-file
;; C-u C-c C-l 	 nyquist-load-file-protected (Ruby only)
;;
;; and in addition:
;; 
;; C-c C-f   	 nyquist-file    	   open view-files-dialog of Nyquist
;; C-c C-p   	 nyquist-play    	   play current sound file
;; C-c C-t   	 nyquist-stop    	   stop playing all sound files
;; C-c C-i   	 nyquist-help    	   help on Nyquist-function (nyquist-help)
;; C-u C-c C-i   nyquist-help-html 	   help on Nyquist-function (html)
;; C-c C-q   	 nyquist-quit    	   send exit to Nyquist process
;; C-c C-k   	 nyquist-kill    	   kill Nyquist process and buffer

;;; News:
;;
;; All variables and functions containing the string `guile' are
;; renamed to `lisp'.  It exists aliases for the following functions
;; and variables:
;;
;; new name                     alias for backward compatibility
;; 
;; run-nyquist-lisp	        run-nyquist-guile	       
;; nyquist-lisp-mode-hook	      	nyquist-guile-mode-hook	      
;; nyquist-lisp-mode	      	nyquist-guile-mode	      
;; inf-nyquist-lisp-mode	      	inf-nyquist-guile-mode	      
;; inf-nyquist-lisp-quit-hook   	inf-nyquist-guile-quit-hook   
;; inf-nyquist-lisp-program-name	inf-nyquist-guile-program-name

;;; Code:

(require 'comint)
;; (require 'lisp)
;; (require 'cmulisp)
(require 'lisp-mode)

(defconst inf-nyquist-version "25-Mar-2007"
  "Version date of inf-nyquist.el.")

;; nyquist-lisp
(defvar inf-nyquist-lisp-buffer "*Nyquist-Lisp*"
  "Inferior Nyquist-Lisp process buffer.")

(defvar inf-nyquist-lisp-buffer-name "Nyquist-Lisp"
  "Inferior Nyquist-Lisp process buffer name.")

(defvar inf-nyquist-lisp-mode-hook nil
  "*User hook variable of `inf-nyquist-lisp-mode'.
Will be called after `comint-mode-hook' and before starting
inferior Nyquist-Lisp process.")

(defvar inf-nyquist-lisp-quit-hook nil
  "*User hook variable of `inf-nyquist-lisp-mode'.
Will be called before finishing inferior Nyquist-Lisp process.")

(defvar inf-nyquist-lisp-program-name "nyquist-guile"
  "*User variable to set Nyquist-Lisp-program name and optional args.")

(if (fboundp 'defvaralias)
    (progn
      (defvaralias 'inf-nyquist-guile-mode-hook    'inf-nyquist-lisp-mode-hook)
      (defvaralias 'inf-nyquist-guile-quit-hook    'inf-nyquist-lisp-quit-hook)
      (defvaralias 'inf-nyquist-guile-program-name 'inf-nyquist-lisp-program-name)))

;; general
(defvar nyquist-completions-buffer "*Completions*"
  "Nyquist completions buffer.")

(defvar inf-nyquist-prompt ">"
  "*User variable to determine Nyquist's listener prompt.
Example: (setq inf-nyquist-prompt \"nyquist> \")")

(defvar inf-nyquist-working-directory "~/"
  "*User variable where Emacs will find the Ruby, Forth, or Lisp scripts.")

(defvar inf-nyquist-kind nil
  "Options are 'ruby, 'forth, or 'lisp.
Needed to determine which extension language to use.  This variable is
buffer-local.")

(defvar inf-nyquist-comint-line-end "\n"
  "*User variable for terminating comint-send.
Interesting perhaps only for Nyquist-Forth.  The default '\n' should
be changed to '\n\n' with nyquist-forth-xm and nyquist-forth-xg but not
with nyquist-forth-nogui.  A double carriage return forces a prompt
while a single carriage return does it not in every case.")

(defvar inf-nyquist-index-path "~/"
  "*User variable to path where nyquist-xref.c is located.")

(defvar nyquist-send-eval-file (expand-file-name
			    (concat
			     (user-login-name) "-nyquist-eval-file.rb") temporary-file-directory)
  "*User variable of `inf-nyquist-ruby-mode' and `nyquist-ruby-mode'.
File where the commands will be collected before sending to
inferior Nyquist process.")

(defvar inf-nyquist-to-comment-regexp "^\\(Exception\\|undefined\\|([-A-Za-z]+)\\)"
  "*User variable of `inf-nyquist-ruby-mode'.
Lines with regexp will be prepended by ruby's comment sign and space '# '.")

(defvar inf-nyquist-lisp-keywords nil
  "Nyquist keywords providing online help.
\\<inf-nyquist-lisp-mode-map> Will be used by
`inf-nyquist-help' (\\[inf-nyquist-help], \\[universal-argument]
\\[inf-nyquist-help]) and `nyquist-help' (\\[nyquist-help],
\\[universal-argument] \\[nyquist-help]), taken from
nyquist/nyquist-xref.c.  The user variable `inf-nyquist-index-path' should
point to the correct path where nyquist-xref.c is located.")

(defvar inf-nyquist-lisp-keyword-regexp "^  \"\\([-A-Za-z0-9*>?!()]+?\\)\"[,}]+?"
  "*User variable to find Nyquist-Lisp's and Nyquist-Forth's keywords in nyquist-xref.c.")

(defun inf-nyquist-set-keywords ()
  "Set the keywords for `inf-nyquist-help'.
The user variable `inf-nyquist-index-path' should point to the
correct path of nyquist-xref.c to create valid keywords."
  (let ((fbuf (find-file-noselect (concat (expand-file-name inf-nyquist-index-path) "nyquist-xref.c")))
	(regex (if (eq 'ruby inf-nyquist-kind)
		   inf-nyquist-ruby-keyword-regexp
		 inf-nyquist-lisp-keyword-regexp))
	(keys '()))
    (with-current-buffer fbuf
      (goto-char (point-min))
      (setq case-fold-search nil)
      (while (re-search-forward regex nil t)
	(let ((val (match-string 1)))
	  (or (member val keys)
	      (setq keys (cons val keys))))))
    (kill-buffer fbuf)
    keys))

;;; from share/emacs/22.0.50/lisp/thingatpt.el
;;; lisp-complete-symbol (&optional predicate)
(defun nyquist-completion ()
  "Perform completion on symbols preceding point.
Compare that symbol against the known Nyquist symbols.
If no characters can be completed, display a list of possible completions.
Repeating the command at that point scrolls the list."
  (interactive)
  (let ((window (get-buffer-window nyquist-completions-buffer)))
    (if (and (eq last-command this-command)
	     window (window-live-p window) (window-buffer window)
	     (buffer-name (window-buffer window)))
	;; If this command was repeated, and
	;; there's a fresh completion window with a live buffer,
	;; and this command is repeated, scroll that window.
	(with-current-buffer (window-buffer window)
	  (if (pos-visible-in-window-p (point-max) window)
	      (set-window-start window (point-min))
	    (save-selected-window
	      (select-window window)
	      (scroll-up))))
      ;; Do completion.
      (let* ((end (point))
	     (beg (save-excursion
		    (backward-sexp 1)
		    (while (= (char-syntax (following-char)) ?\')
		      (forward-char 1))
		    (point)))
	     (pattern (buffer-substring-no-properties beg end))
	     (key-list (if (eq 'ruby inf-nyquist-kind) inf-nyquist-ruby-keywords inf-nyquist-lisp-keywords))
	     (completion (try-completion pattern key-list)))
	(cond ((eq completion t))
	      ((null completion)
	       (message "Can't find completion for \"%s\"" pattern))
	      ((not (string= pattern completion))
	       (delete-region beg end)
	       (insert completion))
	      (t
	       (let ((list (all-completions pattern key-list)))
		 (setq list (sort list 'string<))
		 (with-output-to-temp-buffer nyquist-completions-buffer
		   (display-completion-list list)))))))))

(defun inf-nyquist-set-keys (mode name)
  "Set the key bindings and menu entries for MODE.
Menu name is NAME.  You can extend the key bindings and menu entries
here or via hook variables in .emacs file."
  ;; key bindings
  (define-key (current-local-map) "\C-c\C-f" 'inf-nyquist-file)
  (define-key (current-local-map) "\M-\C-l"  'inf-nyquist-load)
  (define-key (current-local-map) "\M-\C-p"  'inf-nyquist-play)
  (define-key (current-local-map) "\C-c\C-s" 'inf-nyquist-run-nyquist)
  (define-key (current-local-map) "\C-c\C-t" 'inf-nyquist-stop)
  (define-key (current-local-map) "\C-c\C-i" 'inf-nyquist-help)
  (define-key (current-local-map) "\C-c\C-k" 'inf-nyquist-kill)
  (define-key (current-local-map) "\C-c\C-q" 'inf-nyquist-quit)
  (define-key (current-local-map) "\e\C-i"   'nyquist-completion)
  ;; menu entries in reverse order of appearance
  (define-key (current-local-map) [menu-bar mode]
    (cons name (make-sparse-keymap name)))
  (define-key (current-local-map) [menu-bar mode kill]
    '(menu-item "Kill Nyquist Process and Buffer" inf-nyquist-kill
		:enable (inf-nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode quit]
    '(menu-item "Send exit to Nyquist Process" inf-nyquist-quit
		:enable (inf-nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode start-g]
    '(menu-item "Start Nyquist-Lisp Process" inf-nyquist-run-nyquist
		:enable (not (inf-nyquist-proc-p))
		:visible (eq 'lisp inf-nyquist-kind)))
  (define-key (current-local-map) [menu-bar mode sep-quit] '(menu-item "--"))
  (define-key (current-local-map) [menu-bar mode desc]
    '(menu-item "Describe Mode" describe-mode))
  (define-key (current-local-map) [menu-bar mode help-html]
    '(menu-item "Describe Nyquist Function (html) ..." inf-nyquist-help-html
		:enable (inf-nyquist-proc-p)
		:visible (not (eq 'ruby inf-nyquist-kind))))
  (define-key (current-local-map) [menu-bar mode help]
    '(menu-item "Describe Nyquist Function (nyquist-help) ..." inf-nyquist-help
		:enable (inf-nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode sep-reset] '(menu-item "--"))
  (define-key (current-local-map) [menu-bar mode stop]
    '(menu-item "Stop Playing" inf-nyquist-stop
		:enable (inf-nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode play]
    '(menu-item "Start Playing" inf-nyquist-play
		:enable (inf-nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode file]
    '(menu-item "Open Nyquist-File Dialog" inf-nyquist-file
		:enable (inf-nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode sep-play] '(menu-item "--"))
  (define-key (current-local-map) [menu-bar mode load-g]
    '(menu-item "Load Lisp Script ..." inf-nyquist-load
		:enable (inf-nyquist-proc-p)
		:visible (eq 'lisp inf-nyquist-kind))))
	  
(defun inf-nyquist-send-string (str &optional no-strip-p)
  "Print STR in buffer and send it to the inferior Nyquist process.
If NO-STRIP-P is nil, the default, all dashes (-) will be translated
to underlines (_), if `inf-nyquist-kind' is 'ruby.  If NO-STRIP-P is
non-nil, it won't translate.  See `inf-nyquist-load' for the latter case."
  (interactive)
  (and (not no-strip-p)
       (eq 'ruby inf-nyquist-kind)
       (while (string-match "-" str)
	 (setq str (replace-match "_" t nil str))))
  (if (eq 'lisp inf-nyquist-kind)
      (setq str (concat "(" str ")")))
  (with-current-buffer (inf-nyquist-proc-buffer)
    (insert str)
    (comint-send-input)))

(defun inf-nyquist-run-nyquist ()
  "Start inferior Nyquist-Ruby, Nyquist-Forth, or Nyquist-Lisp process.
Started from dead Nyquist process buffer."
  (interactive)
  (run-nyquist-lisp inf-nyquist-lisp-program-name))

(defun inf-nyquist-file ()
  "Open Nyquist's view-files-dialog widget."
  (interactive)
  (inf-nyquist-send-string "view-files-dialog"))

(defun inf-nyquist-load (file)
  "Load the required Ruby, Forth, or Lisp script.
Asks for FILE interactively in minibuffer."
  (interactive "fLoad Nyquist Script: ")
  (unless (file-directory-p file)
    (inf-nyquist-send-string
     (format "load %S" (car (file-expand-wildcards file t)))) t))

(defun inf-nyquist-play ()
  "Play current sound."
  (interactive)
  (inf-nyquist-send-string "play"))

(defun inf-nyquist-stop ()
  "Stop playing of all sound files."
  (interactive)
  (inf-nyquist-send-string "stop-playing"))

(defun inf-nyquist-help (&optional html-help)
  "Receive a string in minibuffer and show corresponding help.
\\<inf-nyquist-ruby-mode-map>\\<inf-nyquist-forth-mode-map>\\<inf-nyquist-lisp-mode-map>
This is done via Nyquist's function nyquist_help() or html() if HTML-HELP
is non-nil, i.e. it's called by \\[universal-argument]
\\[inf-nyquist-help], putting result at the end of the inferior Nyquist
process buffer.  If point is near a function name in inferior Nyquist
process buffer, that function will be used as default value in
minibuffer; tab-completion is activated.  `inf-nyquist-ruby-keywords'
and `inf-nyquist-lisp-keywords' hold the help strings, the user
variable `inf-nyquist-index-path' should point to the correct path of
nyquist-xref.c."
  (interactive "P")
  (let ((prompt (format "Nyquist%s Help: " (if html-help " HTML" "")))
	(default (thing-at-point 'sexp)))
    (if default
	(setq prompt (format "%s(default %s): " prompt default)))
    (let ((str (completing-read prompt
				(if (eq 'ruby inf-nyquist-kind)
				    inf-nyquist-ruby-keywords
				  inf-nyquist-lisp-keywords)
				nil nil nil nil default)))
      (unless (string= str "")
	(unless html-help
	  (while (string-match " " str)
	    (setq str (replace-match "" t nil str))))
	(let ((inf-str (if (and html-help
				(not (eq 'forth inf-nyquist-kind)))
			   (format "(html \"%s\")" str)
			 (cond ((eq 'ruby inf-nyquist-kind)
				(format "Nyquist.display(nyquist_help(\"%s\", true))" str))
			       ((eq 'forth inf-nyquist-kind)
				(format "\"%s\" t nyquist-help" str))
			       (t
				(format "nyquist-help \"%s\" t" str))))))
	  (with-current-buffer (inf-nyquist-proc-buffer)
	    (goto-char (point-max))
	    (if (and (string= (char-to-string (preceding-char)) inf-nyquist-prompt)
		     (eobp))
		(inf-nyquist-send-string inf-str t)
	      (beginning-of-line)
	      (kill-region (point) (point-max))
	      (inf-nyquist-send-string inf-str t)
	      (yank))))))))

(defun inf-nyquist-help-html ()
  "Start html help."
  (interactive)
  (inf-nyquist-help t))

(defun inf-nyquist-quit ()
  "Send exit to inferior Nyquist process."
  (interactive)
  (run-hooks 'inf-nyquist-lisp-quit-hook)
  (if (bufferp nyquist-completions-buffer)
      (kill-buffer nyquist-completions-buffer))
  (get-buffer-process (inf-nyquist-proc-buffer))
  (goto-char (point-max))
  (nyquist-send-invisible "(exit 0)")
  (and (file-exists-p nyquist-send-eval-file)
       (delete-file nyquist-send-eval-file)))

(defun inf-nyquist-kill ()
  "Kill current inferior Nyquist process and buffer."
  (interactive)
  (inf-nyquist-quit)
  (delete-process (get-buffer-process (inf-nyquist-proc-buffer)))
  (kill-buffer (current-buffer))
  (unless (one-window-p)
    (delete-window (get-buffer-window (inf-nyquist-proc-buffer)))))

(defun inf-nyquist-proc-buffer ()
  "Return the current process buffer."
  inf-nyquist-lisp-buffer)

(defun inf-nyquist-proc-p ()
  "Return non-nil if process buffer is available."
  (save-current-buffer
    (comint-check-proc (inf-nyquist-proc-buffer))))

(defun nyquist-send-invisible (str &optional no-newline)
  "Send a STR to the process running in the current buffer.
Non-nil NO-NEWLINE means string without carriage return append."
  (let ((proc (get-buffer-process (current-buffer))))
    (cond ((not proc)
	   (error "Current buffer has no process"))
	  ((stringp str)
	   (comint-snapshot-last-prompt)
	   (if no-newline
	       (comint-send-string proc str)
	     (comint-simple-send proc str))))))
  
(defun inf-nyquist-comint-put-prompt-ruby (string)
  "Look for `inf-nyquist-to-comment-regexp' in STRING in the current output.
Prepends matching lines with ruby's comment sign and space `# '.
Showing a prompt is forced by run_emacs_eval_hook() in
nyquist/examp.rb.  This function could be on the so called abnormal
hook with one arg `comint-preoutput-filter-functions'."
  (if (string-match "\\(^nil\n\\)" string)
      (setq string (replace-match "" t nil string 1)))
  ;; Drop trailing '\n' ("...nyquist(0)> \n" => "...nyquist(0)> ").
  (if (string-match inf-nyquist-prompt string)
      (setq string (substring string 0 -1)))
  (while (string-match inf-nyquist-to-comment-regexp string)
    (setq string (replace-match "# \\1" t nil string 1)))
  string)
  
(defun inf-nyquist-comint-put-prompt-forth (string)
  "If STRING contains a trailing nil, replace it by `inf-nyquist-prompt'.
This function could be on the so called abnormal hook with one
arg `comint-preoutput-filter-functions'."
  (if (string-match "\\(\\(nil\\|#<undef>\\|#<nil>\\)\n$\\)" string)
      (replace-match inf-nyquist-prompt t nil string 1)
    string))

(defun inf-nyquist-comint-put-prompt-lisp (string)
  "Appends `inf-nyquist-prompt' to STRING.
This function could be on the so called abnormal hook with one
arg `comint-preoutput-filter-functions'."
  (if (string-match "\n" string)
      (concat string inf-nyquist-prompt)
    string))

(defun inf-nyquist-comint-nyquist-send (proc line)
  "Special function for sending input LINE to PROC.
Variable `comint-input-sender' is set to this function.  Running
Nyquist-Ruby it is necessary to load nyquist/examp.rb in your ~/.nyquist file
which contains run_emacs_eval_hook(line).  inf-nyquist.el uses this
function to evaluate one line or multi-line input (Ruby only)."
  (if (= (length line) 0)
      (if (eq 'lisp inf-nyquist-kind)
	  (setq line "nil")
	(setq line "nil")))
  (comint-send-string proc (if (eq 'ruby inf-nyquist-kind)
			       (format "run_emacs_eval_hook(%%(%s))\n" line)
			     (concat line inf-nyquist-comint-line-end))))

(defun inf-nyquist-get-old-input ()
  "Snarf the whole pointed line."
  (save-excursion
    (end-of-line)
    (let ((end (point)))
      (beginning-of-line)
      (buffer-substring-no-properties (point) end))))

(defun inf-nyquist-args-to-list (string)
  "Return a list containing the program and optional arguments list.
Argument STRING is the Nyquist command and optional arguments."
  (let ((where (string-match "[ \t]" string)))
    (cond ((null where) (list string))
	  ((not (= where 0))
	   (cons (substring string 0 where)
		 (inf-nyquist-args-to-list (substring string (+ 1 where) (length string)))))
	  (t (let ((pos (string-match "[^ \t]" string)))
	       (if (null pos)
		   nil
		 (inf-nyquist-args-to-list (substring string pos
						 (length string)))))))))

(defun lisp-input-filter (str)
  "Don't save anything matching inferior-lisp-filter-regexp"
  (not (string-match inferior-lisp-filter-regexp str)))

(defvar inferior-lisp-filter-regexp "\\`\\s *\\S ?\\S ?\\s *\\'"
  "*Input matching this regexp are not saved on the history list.
Defaults to a regexp ignoring all inputs of 0, 1, or 2 letters.")

(define-derived-mode inf-nyquist-lisp-mode comint-mode inf-nyquist-lisp-buffer-name
  "Inferior mode running Nyquist-Lisp, derived from `comint-mode'.

Nyquist is a sound editor created by Bill Schottstaedt
\(bil@ccrma.Stanford.EDU).  You can find it on
ftp://ccrma-ftp.stanford.edu/pub/Lisp/nyquist-7.tar.gz.

You can type in Lisp commands in inferior Nyquist process buffer which
will be sent via `comint-send-string' to the inferior Nyquist process.
The return value will be shown in the process buffer, other output
goes to the listener of Nyquist.

You sould set variable `inf-nyquist-lisp-program-name' and
`inf-nyquist-working-directory' in your .emacs file to set the appropriate
program name and optional arguments and to direct Nyquist to the Lisp
scripts directory, you have.

The hook variables `comint-mode-hook' and
`inf-nyquist-lisp-mode-hook' will be called in that special order
after calling the inferior Nyquist process.  You can use them e.g. to
set additional key bindings.  The hook variable
`inf-nyquist-lisp-quit-hook' will be called before finishing the
inferior Nyquist process.  You may use it for resetting Nyquist
variables, e.g. the listener prompt.

\\<inf-nyquist-lisp-mode-map> Interactive start is possible either by
\\[universal-argument] \\[run-nyquist-lisp], you will be ask for the Nyquist
program name, or by \\[run-nyquist-lisp].  Emacs shows an additional menu
entry ``Nyquist-Lisp'' in the menu bar.

The following key bindings are defined:
\\{inf-nyquist-lisp-mode-map}"
  (lisp-mode-variables)
  (add-hook 'comint-preoutput-filter-functions 'inf-nyquist-comint-put-prompt-lisp nil t)
  (add-hook 'comint-input-filter-functions 'lisp-input-filter nil t)
  (setq comint-get-old-input (function lisp-get-old-input))
  (setq comint-input-sender (function inf-nyquist-comint-nyquist-send))
  (setq default-directory inf-nyquist-working-directory)
  (make-local-variable 'inf-nyquist-prompt)
  (make-local-variable 'inf-nyquist-kind)
  (make-local-variable 'inf-nyquist-comint-line-end)
  (setq comint-prompt-regexp (concat "^\\(" inf-nyquist-prompt "\\)+"))
  (setq inf-nyquist-kind 'lisp)
  (setq mode-line-process '(":%s"))
  (unless inf-nyquist-lisp-keywords
    (setq inf-nyquist-lisp-keywords (inf-nyquist-set-keywords)))
  (inf-nyquist-set-keys 'inf-nyquist-lisp-mode inf-nyquist-lisp-buffer-name)
  (pop-to-buffer inf-nyquist-lisp-buffer)
  (goto-char (point-max))
  (run-hooks 'inf-nyquist-lisp-mode-hook))

(defalias 'inf-nyquist-guile-mode 'inf-nyquist-lisp-mode)


(defun run-nyquist-lisp (cmd)
  "Start inferior Nyquist-Lisp process.
CMD is used for determine which program to run.  If interactively
called, one will be asked for program name to run."
  (interactive (list (if current-prefix-arg
 			 (read-string "Run Nyquist Lisp: " inf-nyquist-lisp-program-name)
 		       inf-nyquist-lisp-program-name)))
  (unless (comint-check-proc inf-nyquist-lisp-buffer)
    (let ((cmdlist (inf-nyquist-args-to-list cmd)))
      (setq inf-nyquist-lisp-program-name cmd)
      (set-buffer (apply 'make-comint inf-nyquist-lisp-buffer-name (car cmdlist) nil (cdr cmdlist))))
    (inf-nyquist-lisp-mode)
    (nyquist-send-invisible "nil")))

(defalias 'run-nyquist-guile 'run-nyquist-lisp)

;;;; The nyquist-ruby-, nyquist-lisp-, and nyquist-forth-mode

;;; Commentary:

;; These three modes are derived from ruby-mode, lisp-mode, and
;; forth-mode.  The main changes are the key bindings, which now refer
;; to special Nyquist-process-buffer-related ones.  I took commands from
;; inf-ruby.el, from cmulisp.el and from gforth.el and changed them
;; appropriately.

(defvar nyquist-lisp-buffer-name "Nyquist"
  "Buffer name of `nyquist-lisp-mode'.")

(defvar nyquist-lisp-mode-hook nil
  "*User hook variable.
Called after `lisp-mode-hook' and before starting inferior Nyquist
process.")

(defalias 'nyquist-guile-mode-hook 'nyquist-lisp-mode-hook)

(defvar nyquist-source-modes '(nyquist-ruby-mode)
  "Used to determine if a buffer contains Nyquist source code.
If it's loaded into a buffer that is in one of these major modes, it's
considered a Nyquist source file by `nyquist-load-file'.  Used by this command
to determine defaults.  This variable is buffer-local in
`nyquist-ruby-mode', `nyquist-forth-mode' and `nyquist-lisp-mode'.")

(defvar nyquist-inf-kind 'lisp
  "Options are 'ruby, 'forth, and 'lisp.
Needed to determine which extension language should be used.
This variable is buffer-local in `nyquist-ruby-mode',
`nyquist-forth-mode', and `nyquist-lisp-mode'.")

(defvar nyquist-prev-l/c-dir/file nil
  "Cache the (directory . file) pair used in the last `nyquist-load-file'.
Used for determining the default in the next one.")

(define-derived-mode nyquist-lisp-mode lisp-mode nyquist-lisp-buffer-name
  "Major mode for editing Nyquist-Lisp code.

Editing commands are similar to those of `lisp-mode'.

In addition, you can start an inferior Nyquist process and some
additional commands will be defined for evaluating expressions.
A menu ``Nyquist'' appears in the menu bar.  Entries in this
menu are disabled if no inferior Nyquist process exist.

You can use variables `lisp-mode-hook' and
`nyquist-lisp-mode-hook', which will be called in that order.

The current key bindings are:
\\{nyquist-lisp-mode-map}"
  (make-local-variable 'nyquist-inf-kind)
  (make-local-variable 'nyquist-source-modes)
  (setq nyquist-inf-kind 'lisp)
  (setq nyquist-source-modes '(nyquist-lisp-mode))
  (unless inf-nyquist-lisp-keywords
    (setq inf-nyquist-lisp-keywords (inf-nyquist-set-keywords)))
  (nyquist-set-keys 'nyquist-lisp-mode nyquist-lisp-buffer-name)
  (run-hooks 'nyquist-lisp-mode-hook))

(defalias 'nyquist-guile-mode 'nyquist-lisp-mode)

(defun nyquist-send-region (start end)
  "Send the current region to the inferior Nyquist process.
START and END define the region."
  (interactive "r")
  (if (eq 'ruby nyquist-inf-kind)
      (progn
	(write-region start end nyquist-send-eval-file nil 0)
 	(comint-send-string
 	 (nyquist-proc)
 	 (format "eval(File.open(%S).read, TOPLEVEL_BINDING, \"(emacs-eval-region)\", 1).inspect \
rescue message(\"(emacs-eval-region): %%s (%%s)\\n%%s\", \
$!.message, $!.class, $!.backtrace.join(\"\\n\"))\n"
 		 nyquist-send-eval-file)))
    (comint-send-region (nyquist-proc) start end)
    (comint-send-string (nyquist-proc) "\n")))

(defun nyquist-send-region-and-go (start end)
  "Send the current region to the inferior Nyquist process.
Switch to the process buffer.  START and END define the region."
  (interactive "r")
  (nyquist-send-region start end)
  (nyquist-switch-to-nyquist t))

(defun nyquist-send-definition (&optional cnt)
  "Send the current or CNT definition to the inferior Nyquist process."
  (interactive "p")
  (save-excursion
    (if (eq 'ruby nyquist-inf-kind)
	(ruby-beginning-of-defun cnt)
      (beginning-of-defun cnt))
   (let ((beg (point)))
     (if (eq 'ruby nyquist-inf-kind)
	 (ruby-end-of-defun)
       (end-of-defun))
     (nyquist-send-region beg (point)))))

(defun nyquist-send-definition-and-go (&optional cnt)
  "Send the current or CNT definition to the inferior Nyquist process.
Switch to the process buffer."
  (interactive "p")
  (nyquist-send-definition cnt)
  (nyquist-switch-to-nyquist t))

(defun nyquist-send-last-sexp (&optional cnt)
  "Send the previous or CNT sexp to the inferior Nyquist process."
  (interactive "p")
  (nyquist-send-region (save-excursion
		     (if (eq 'ruby nyquist-inf-kind)
			 (ruby-backward-sexp cnt)
		       (backward-sexp cnt))
		     (point))
		   (point)))

(defun nyquist-send-block (&optional cnt)
  "Send the current or CNT block to the inferior Nyquist-Ruby process.
Works only in `nyquist-ruby-mode'."
  (interactive "p")
  (save-excursion
    (ruby-beginning-of-block cnt)
    (let ((beg (point)))
      (ruby-end-of-block)
      (end-of-line)
      (nyquist-send-region beg (point)))))

(defun nyquist-send-block-and-go (&optional cnt)
  "Send the current or CNT block to the inferior Nyquist-Ruby process.
Switch to the process buffer.  Works only in `nyquist-ruby-mode'."
  (interactive "p")
  (nyquist-send-block cnt)
  (nyquist-switch-to-nyquist t))

(defun nyquist-send-buffer ()
  "Send the current buffer to the inferior Nyquist process."
  (interactive)
  (nyquist-send-region (point-min) (point-max)))

(defun nyquist-send-buffer-and-go ()
  "Send the current buffer to the inferior Nyquist process.
Switch to the process buffer."
  (interactive)
  (nyquist-send-buffer)
  (nyquist-switch-to-nyquist t))

(defun nyquist-switch-to-nyquist (&optional eob-p)
  "If inferior Nyquist process exists, switch to process buffer, else start Nyquist.
Non-nil EOB-P positions cursor at end of buffer."
  (interactive "P")
  (let ((buf (nyquist-proc-buffer)))
    (if (get-buffer buf)
	(pop-to-buffer buf)
      (nyquist-run-nyquist))
    (if eob-p
	(push-mark)
      (goto-char (point-max)))))

(defun nyquist-run-nyquist ()
  "If inferior Nyquist process exists, switch to process buffer, else start Nyquist.
Started from `nyquist-ruby-mode', `nyquist-forth-mode' or `nyquist-lisp-mode'."
  (interactive)
  (if (nyquist-proc-p)
      (progn
	(pop-to-buffer (nyquist-proc-buffer))
	(push-mark)
	(goto-char (point-max)))
    (cond ((eq 'ruby nyquist-inf-kind)
	   (run-nyquist-ruby inf-nyquist-ruby-program-name))
	  ((eq 'forth nyquist-inf-kind)
	   (run-nyquist-forth inf-nyquist-forth-program-name))
	  (t
	   (run-nyquist-lisp inf-nyquist-lisp-program-name)))))

(defun nyquist-load-file-protected (filename)
  "Load a Ruby script FILENAME as an anonymous module into the inferior Nyquist process."
  (interactive (comint-get-source "Load Nyquist script file: "
				  nyquist-prev-l/c-dir/file nyquist-source-modes t))
  (comint-check-source filename)
  (setq nyquist-prev-l/c-dir/file (cons (file-name-directory filename)
				     (file-name-nondirectory filename)))
  (comint-send-string (nyquist-proc) (concat "load(\"" filename "\", true)\n")))

(defun nyquist-load-file (filename)
  "Load a Nyquist script FILENAME into the inferior Nyquist process."
  (interactive (comint-get-source "Load Nyquist script file: "
				  nyquist-prev-l/c-dir/file nyquist-source-modes t))
  (comint-check-source filename)
  (setq nyquist-prev-l/c-dir/file (cons (file-name-directory filename)
				     (file-name-nondirectory filename)))
  (if (eq 'forth nyquist-inf-kind)
      (comint-send-string (nyquist-proc) (concat "include " filename "\n"))
    (comint-send-string (nyquist-proc) (concat "(load \"" filename"\"\)\n"))))

(defun nyquist-save-state ()
  "Synchronize the inferior Nyquist process with the edit buffer."
  (and (nyquist-proc)
       (setq inf-nyquist-kind nyquist-inf-kind)))
  
(defun nyquist-file ()
  "Open Nyquist's view-files-dialog widget."
  (interactive)
  (nyquist-save-state)
  (inf-nyquist-file))

(defun nyquist-play ()
  "Play current sound."
  (interactive)
  (nyquist-save-state)
  (inf-nyquist-play))

(defun nyquist-stop ()
  "Stop playing of all sounds."
  (interactive)
  (nyquist-save-state)
  (inf-nyquist-stop))

(defun nyquist-help (&optional html-help)
  "Receive a string in minibuffer and show corresponding help.
\\<inf-nyquist-ruby-mode-map>\\<inf-nyquist-forth-mode-map>\\<inf-nyquist-lisp-mode-map>
This is done via Nyquist's function nyquist_help() or html() if HTML-HELP
is non-nil, i.e. it's called by \\[universal-argument]
\\[nyquist-help], putting result at the end of the inferior Nyquist
process buffer.  If point is near a function name in inferior Nyquist
process buffer, that function will be used as default value in
minibuffer; tab-completion is activated.  `inf-nyquist-ruby-keywords'
and `inf-nyquist-lisp-keywords' hold the help strings, the user
variable `inf-nyquist-index-path' should point to the correct path of
nyquist-xref.c."
  (interactive "P")
  (nyquist-save-state)
  (inf-nyquist-help html-help))

(defun nyquist-help-html ()
  "Start html help."
  (interactive)
  (nyquist-help t))

(defun nyquist-quit ()
  "Send exit to current inferior Nyquist process."
  (interactive)
  (nyquist-save-state)
  (save-excursion
    (nyquist-switch-to-nyquist t)
    (inf-nyquist-quit)))

(defun nyquist-kill ()
  "Kill current inferior Nyquist process buffer."
  (interactive)
  (nyquist-save-state)
  (save-excursion
    (nyquist-switch-to-nyquist t)
    (inf-nyquist-kill)))

(defun nyquist-proc-buffer ()
  "Return the current process buffer."
  (cond ((eq 'ruby nyquist-inf-kind)
	 inf-nyquist-ruby-buffer)
	((eq 'forth nyquist-inf-kind)
	 inf-nyquist-forth-buffer)
	(t
	 inf-nyquist-lisp-buffer)))

(defun nyquist-proc ()
  "Return the process buffer."
  (let* ((buf (nyquist-proc-buffer))
	 (proc (get-buffer-process (if (eq major-mode
					   (cond ((eq 'ruby nyquist-inf-kind)
						  'inf-nyquist-ruby-mode)
						 ((eq 'forth nyquist-inf-kind)
						  'inf-nyquist-forth-mode)
						 ('
						  'inf-nyquist-lisp-mode)))
				       (current-buffer)
				     buf))))
    (or proc
	(error "No current process.  See variable inf-nyquist-ruby|inf-nyquist-forth|lisp-buffer"))))

(defun nyquist-proc-p ()
  "Return non-nil if no process buffer available."
  (save-current-buffer
    (comint-check-proc (nyquist-proc-buffer))))

(defun nyquist-set-keys (mode name)
  "Set the key bindings and menu entries for MODE.
Menu name is NAME.  You can extend the key bindings and menu entries
here or via hook variables in .emacs file."
  (define-key (current-local-map) "\M-\C-x"  'nyquist-send-definition)
  (define-key (current-local-map) "\C-x\C-e" 'nyquist-send-last-sexp)
  (define-key (current-local-map) "\C-c\M-e" 'nyquist-send-definition)
  (define-key (current-local-map) "\C-c\C-e" 'nyquist-send-definition-and-go)
  (define-key (current-local-map) "\C-c\M-r" 'nyquist-send-region)
  (define-key (current-local-map) "\C-c\C-r" 'nyquist-send-region-and-go)
  (define-key (current-local-map) "\C-c\M-o" 'nyquist-send-buffer)
  (define-key (current-local-map) "\C-c\C-o" 'nyquist-send-buffer-and-go)
  (define-key (current-local-map) "\C-c\C-z" 'nyquist-switch-to-nyquist)
  (define-key (current-local-map) "\C-c\C-s" 'nyquist-run-nyquist)
  (define-key (current-local-map) "\C-c\C-l" 'nyquist-load-file)
  (define-key (current-local-map) "\C-c\C-f" 'nyquist-file)
  (define-key (current-local-map) "\C-c\C-p" 'nyquist-play)
  (define-key (current-local-map) "\C-c\C-t" 'nyquist-stop)
  (define-key (current-local-map) "\C-c\C-i" 'nyquist-help)
  (define-key (current-local-map) "\C-c\C-k" 'nyquist-kill)
  (define-key (current-local-map) "\C-c\C-q" 'nyquist-quit)
  (define-key (current-local-map) "\e\C-i"   'nyquist-completion)
  (if (eq 'ruby nyquist-inf-kind)
      (progn
	(define-key (current-local-map) "\C-c\M-b" 'nyquist-send-block)
	(define-key (current-local-map) "\C-c\C-b" 'nyquist-send-block-and-go)
	(define-key (current-local-map) "\C-cb"    'undefined) ;overwrite inf-ruby-commands
	(define-key (current-local-map) "\C-cr"    'undefined) ;C-c + single letter key
	(define-key (current-local-map) "\C-ce"    'undefined) ;is reserved for user
	(define-key (current-local-map) "\C-c\C-x" 'undefined) ;key bindings
	(define-key (current-local-map) "\C-c\M-x" 'undefined))
    (define-key (current-local-map) "\C-c\C-c" 'undefined) ;no compile
    (define-key (current-local-map) "\C-c\M-c" 'undefined))
  (define-key (current-local-map) [menu-bar mode]
    (cons name (make-sparse-keymap name)))
  (define-key (current-local-map) [menu-bar mode kill]
    '(menu-item "Kill Nyquist Process and Buffer" nyquist-kill
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode quit]
    '(menu-item "Send exit to Nyquist Process" nyquist-quit
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode sep-quit] '(menu-item "--"))
  (define-key (current-local-map) [menu-bar mode desc]
    '(menu-item "Describe Mode" describe-mode))
  (define-key (current-local-map) [menu-bar mode help-html]
    '(menu-item "Describe Nyquist Function (html) ..." nyquist-help-html
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode help]
    '(menu-item "Describe Nyquist Function (nyquist-help) ..." nyquist-help
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode sep-desc] '(menu-item "--"))
  (define-key (current-local-map) [menu-bar mode stop]
    '(menu-item "Stop Playing" nyquist-stop
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode play]
    '(menu-item "Start Playing" nyquist-play
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode file]
    '(menu-item "Open Nyquist-File Dialog" nyquist-file
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode sep-load] '(menu-item "--"))
  (define-key (current-local-map) [menu-bar mode start-r]
    '(menu-item "Start Nyquist-Ruby Process" nyquist-run-nyquist
		:enable (not (nyquist-proc-p))
		:visible (eq 'ruby nyquist-inf-kind)))
  (define-key (current-local-map) [menu-bar mode start-f]
    '(menu-item "Start Nyquist-Forth Process" nyquist-run-nyquist
		:enable (not (nyquist-proc-p))
		:visible (eq 'forth nyquist-inf-kind)))
  (define-key (current-local-map) [menu-bar mode start-g]
    '(menu-item "Start Nyquist-Lisp Process" nyquist-run-nyquist
		:enable (not (nyquist-proc-p))
		:visible (eq 'lisp nyquist-inf-kind)))
  (define-key (current-local-map) [menu-bar mode switch]
    '(menu-item "Switch to Nyquist Process" nyquist-switch-to-nyquist
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode sep-proc] '(menu-item "--"))
  (define-key (current-local-map) [menu-bar mode block-go]
    '(menu-item "Send Block and Go" nyquist-send-block-and-go
		:enable (nyquist-proc-p)
		:visible (eq 'ruby nyquist-inf-kind)))
  (define-key (current-local-map) [menu-bar mode block]
    '(menu-item "Send Block" nyquist-send-block
		:enable (nyquist-proc-p)
		:visible (eq 'ruby nyquist-inf-kind)))
  (define-key (current-local-map) [menu-bar mode buffer-go]
    '(menu-item "Send Buffer and Go" nyquist-send-buffer-and-go
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode buffer]
    '(menu-item "Send Buffer" nyquist-send-buffer
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode region-go]
    '(menu-item "Send Region and Go" nyquist-send-region-and-go
		:enable (and (nyquist-proc-p) mark-active)))
  (define-key (current-local-map) [menu-bar mode region]
    '(menu-item "Send Region" nyquist-send-region
		:enable (and (nyquist-proc-p) mark-active)))
  (define-key (current-local-map) [menu-bar mode def-go]
    '(menu-item "Send Definition and Go" nyquist-send-definition-and-go
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode def]
    '(menu-item "Send Definition" nyquist-send-definition
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode last-sexp]
    '(menu-item "Send last Sexp" nyquist-send-last-sexp
		:enable (nyquist-proc-p)))
  (define-key (current-local-map) [menu-bar mode sep-load] '(menu-item "--"))
  (define-key (current-local-map) [menu-bar mode load-g]
    '(menu-item "Load Lisp Script ..." nyquist-load-file
		:enable (nyquist-proc-p)
		:visible (eq 'lisp nyquist-inf-kind))))

(provide 'inf-nyquist)

;;; inf-nyquist.el ends here
