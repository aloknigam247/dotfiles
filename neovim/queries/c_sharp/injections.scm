;; extends

; Inject xml into C# /// doc comments, per-line (no injection.combined: combining
; merges every doc comment in the file into one xml tree, which breaks after the
; first ~dozen blocks due to multiple root elements).
((comment) @injection.content
  (#lua-match? @injection.content "^///")
  (#set! injection.language "xml"))
