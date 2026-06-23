;; extends

; Inject luadoc into ---@... / ---| doc comments.
; Builtin lua injections (Neovim core) lack a luadoc rule, and nvim-treesitter's
; own lua/injections.scm appends a catch-all (comment)->"comment" rule that would
; override luadoc. Vendoring just this rule on top of the builtin keeps luadoc
; highlighting working without pulling NT's catch-all.
(comment
  content: (_) @injection.content
  (#lua-match? @injection.content "^[-][%s]*[@|]")
  (#set! injection.language "luadoc")
  (#offset! @injection.content 0 1 0 0))
