(require 'ert)

(cd "/Users/robnea/dev/rneatherway-fsharpbinding/emacs/test")

(ert-deftest start-completion-process ()
  "Check that we can start the completion process and request help"
  (load-fsharp-mode)
  (let ((buf (find-file "Test1/Program.fs")))
    (ac-fsharp-launch-completion-process)
    (should (buffer-live-p (get-buffer "*fsharp-complete*")))
    (should (process-live-p (get-process "fsharp-complete")))
    (process-send-string "fsharp-complete" "help\n")
    (switch-to-buffer "*fsharp-complete*")
    (should (search-backward "trigger completion request" nil t))
    (ac-fsharp-quit-completion-process)
    (kill-process (get-process "fsharp-complete"))
    (kill-buffer "*fsharp-complete*")
    (kill-buffer buf)))

(ert-deftest simple-runthrough ()
  "Just a quick run-through of the main features"
  (load-fsharp-mode)
  (find-file "Test1/Program.fs")
  (ac-fsharp-load-project "Test1.fsproj")
  (should (and (string-match-p "Test1/Program.fs" (mapconcat 'identity ac-fsharp-project-files ""))
               (string-match-p "Test1/FileTwo.fs" (mapconcat 'identity ac-fsharp-project-files ""))))
  (search-forward "X.func")
  (delete-backward-char 2)
  (sleep-for 1.0)
  (completion-at-point)
  (beginning-of-line)
  (should (search-forward "X.func"))
  (backward-char 2)
  ;(ac-fsharp-gotodefn-at-point)
  ;(should (eq (point) 18))
  (beginning-of-line)
  (search-forward "X.func")
  (delete-backward-char 1)
  (backward-char)
  (ac-fsharp-get-errors)
  (should (eq (length (overlays-at (point))) 1))
  (should (eq (overlay-get (car (overlays-at (point))) 'face)
              'fsharp-error-face))
  (kill-process (get-process "fsharp-complete"))
  (kill-buffer "*fsharp-complete*")
  (kill-buffer "Program.fs"))
