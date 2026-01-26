-- Capture syntax highlighting colors from Neovim for Glow themes
-- Run in Neovim: :luafile capture-syntax-colors.lua
-- Output will be saved to: glow/syntax-colors-output.txt

local output_file = vim.fn.expand("~") .. "/dotfiles/glow/syntax-colors-output.txt"
-- Fallback for Windows
if vim.fn.has("win32") == 1 then
  output_file = "d:/dotfiles/glow/syntax-colors-output.txt"
end

local lines = {}
local function log(s)
  table.insert(lines, s)
end

local function hex(n)
  if n then
    return string.format("#%06x", n)
  end
  return nil
end

local function get_hl(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if ok and hl and (hl.fg or hl.bg) then
    return {
      fg = hex(hl.fg),
      bg = hex(hl.bg),
      bold = hl.bold or nil,
      italic = hl.italic or nil,
    }
  end
  return nil
end

-- Map Glow/Chroma token names to Neovim highlight groups
local mappings = {
  -- Text
  { chroma = "text", groups = { "@text", "Normal", "@none" } },

  -- Errors
  { chroma = "error", groups = { "@error", "Error", "DiagnosticError" } },

  -- Comments
  { chroma = "comment", groups = { "@comment", "Comment" } },
  { chroma = "comment_preproc", groups = { "@keyword.directive", "@preproc", "PreProc" } },

  -- Keywords
  { chroma = "keyword", groups = { "@keyword", "Keyword" } },
  { chroma = "keyword_reserved", groups = { "@keyword.return", "@keyword.conditional", "Conditional" } },
  { chroma = "keyword_namespace", groups = { "@keyword.import", "@include", "Include" } },
  { chroma = "keyword_type", groups = { "@type", "Type" } },

  -- Operators and punctuation
  { chroma = "operator", groups = { "@operator", "Operator" } },
  { chroma = "punctuation", groups = { "@punctuation.delimiter", "Delimiter" } },

  -- Names
  { chroma = "name", groups = { "@variable", "Identifier" } },
  { chroma = "name_attribute", groups = { "@attribute", "@property", "@field" } },
  { chroma = "name_class", groups = { "@type", "@constructor", "Type" } },
  { chroma = "name_constant", groups = { "@constant", "Constant" } },
  { chroma = "name_decorator", groups = { "@attribute", "@decorator", "Special" } },
  { chroma = "name_exception", groups = { "@exception", "Exception" } },
  { chroma = "name_function", groups = { "@function", "Function" } },
  { chroma = "name_other", groups = { "@variable", "Identifier" } },
  { chroma = "name_tag", groups = { "@tag", "Tag" } },
  { chroma = "name_variable", groups = { "@variable", "Identifier" } },
  { chroma = "name_builtin", groups = { "@variable.builtin", "@function.builtin", "Special" } },

  -- Literals
  { chroma = "literal", groups = { "@constant", "Constant" } },
  { chroma = "literal_date", groups = { "@string.special", "@number", "Number" } },
  { chroma = "literal_string", groups = { "@string", "String" } },
  { chroma = "literal_string_escape", groups = { "@string.escape", "SpecialChar" } },
  { chroma = "literal_string_interpol", groups = { "@string.special", "SpecialChar" } },
  { chroma = "literal_string_regex", groups = { "@string.regexp", "@string.regex", "SpecialChar" } },
  { chroma = "literal_string_symbol", groups = { "@string.special.symbol", "@symbol", "Special" } },
  { chroma = "literal_number", groups = { "@number", "Number" } },

  -- Generic (diff, etc)
  { chroma = "generic_deleted", groups = { "DiffDelete", "@diff.minus", "diffRemoved" } },
  { chroma = "generic_inserted", groups = { "DiffAdd", "@diff.plus", "diffAdded" } },
  { chroma = "generic_heading", groups = { "@markup.heading", "@text.title", "Title" } },
  { chroma = "generic_strong", groups = { "@markup.strong", "@text.strong", "Bold" } },
  { chroma = "generic_emph", groups = { "@markup.italic", "@text.emphasis", "Italic" } },
  { chroma = "generic_output", groups = { "@comment", "Comment" } },
  { chroma = "generic_prompt", groups = { "@keyword", "Identifier" } },
  { chroma = "generic_subheading", groups = { "@markup.heading", "@text.title", "Title" } },
}

local results = {}

for _, mapping in ipairs(mappings) do
  local found = nil
  local found_group = nil
  for _, group in ipairs(mapping.groups) do
    local hl = get_hl(group)
    if hl then
      found = hl
      found_group = group
      break
    end
  end
  results[mapping.chroma] = {
    hl = found,
    group = found_group,
  }
end

-- Output as JSON-like format for easy reading
log("\n" .. string.rep("=", 60))
log("SYNTAX HIGHLIGHTING COLORS")
log("Current colorscheme: " .. (vim.g.colors_name or "unknown"))
log(string.rep("=", 60))

-- Also get some special colors
local special = {
  { name = "Normal", group = "Normal" },
  { name = "Background", group = "Normal" },
  { name = "Mantle (dark bg)", group = "CursorLine" },
}

log("\n-- Special Colors --")
for _, s in ipairs(special) do
  local hl = get_hl(s.group)
  if hl then
    log(string.format("  %s (%s): fg=%s, bg=%s", s.name, s.group, hl.fg or "nil", hl.bg or "nil"))
  end
end

log("\n-- Glow Chroma Token Colors --")
log("\"chroma\": {")

-- Sort by chroma name for consistent output
local sorted_keys = {}
for k in pairs(results) do
  table.insert(sorted_keys, k)
end
table.sort(sorted_keys)

for i, chroma_name in ipairs(sorted_keys) do
  local data = results[chroma_name]
  if data.hl and data.hl.fg then
    local parts = { string.format("\"color\": \"%s\"", data.hl.fg) }
    if data.hl.bg then
      table.insert(parts, string.format("\"background_color\": \"%s\"", data.hl.bg))
    end
    if data.hl.bold then
      table.insert(parts, "\"bold\": true")
    end
    if data.hl.italic then
      table.insert(parts, "\"italic\": true")
    end
    local comma = i < #sorted_keys and "," or ""
    log(string.format("  \"%s\": { %s }%s  -- from %s",
      chroma_name, table.concat(parts, ", "), comma, data.group or "?"))
  else
    local comma = i < #sorted_keys and "," or ""
    log(string.format("  -- \"%s\": not found (tried: %s)%s",
      chroma_name, table.concat(mappings[i] and mappings[i].groups or {}, ", "), comma))
  end
end

log("}")
log(string.rep("=", 60) .. "\n")

-- Write to file
local file = io.open(output_file, "a")
if file then
  file:write("\n" .. table.concat(lines, "\n") .. "\n")
  file:close()
  vim.notify("Syntax colors written to: " .. output_file, vim.log.levels.INFO)
else
  vim.notify("Failed to write to: " .. output_file, vim.log.levels.ERROR)
end
