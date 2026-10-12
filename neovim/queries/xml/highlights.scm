;; extends

; When xml is injected per-line into C# /// doc comments, a closing line like
; "/// </summary>" has no matching start tag in its fragment, so it parses as
; (ERROR "</" (Name) ">"). The base xml highlights only color a Name inside a
; valid STag/ETag, leaving the closing tag's name unhighlighted (only its < / >
; delimiters render). Anchor on the "</" token so ONLY the closing tag name is
; captured as a tag -- bare text content (e.g. "RPS Version") parses as
; (ERROR (Name) (Name)) and must stay comment-colored, not tag-colored.
((ERROR
  "</"
  (Name) @tag))
