-- Neovim Markdown Highlight Capture Script
-- Run with: nvim -u NONE -c "luafile capture-highlights.lua" test-markdown.md
-- Or from within Neovim: :luafile capture-highlights.lua

local output = {}

local function hex(n)
  if n then
    return string.format("#%06x", n)
  end
  return nil
end

local function get_hl_colors(hl_name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_name, link = false })
  if ok and hl then
    return {
      fg = hex(hl.fg),
      bg = hex(hl.bg),
      bold = hl.bold or false,
      italic = hl.italic or false,
      underline = hl.underline or false,
      strikethrough = hl.strikethrough or false,
    }
  end
  return nil
end

local function add(category, data)
  if not output[category] then
    output[category] = {}
  end
  table.insert(output[category], data)
end

local function capture_buffer_highlights()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Get all extmarks from all namespaces
  local namespaces = vim.api.nvim_get_namespaces()

  for ns_name, ns_id in pairs(namespaces) do
    local extmarks = vim.api.nvim_buf_get_extmarks(buf, ns_id, 0, -1, { details = true })

    for _, mark in ipairs(extmarks) do
      local row, col, details = mark[2], mark[3], mark[4]
      local line_content = lines[row + 1] or ""

      local entry = {
        namespace = ns_name,
        line = row + 1,
        col = col,
        line_text = line_content:sub(1, 60),
      }

      -- Virtual text (icons, prefixes)
      if details.virt_text then
        local virt_parts = {}
        for _, vt in ipairs(details.virt_text) do
          local text, hl = vt[1], vt[2]
          if text and text ~= "" then
            table.insert(virt_parts, {
              text = text,
              hl_group = hl,
              colors = hl and get_hl_colors(hl) or nil,
            })
          end
        end
        if #virt_parts > 0 then
          entry.virt_text = virt_parts
          entry.virt_text_pos = details.virt_text_pos
        end
      end

      -- Highlight group on the text itself
      if details.hl_group then
        entry.hl_group = details.hl_group
        entry.colors = get_hl_colors(details.hl_group)
      end

      -- Line highlight
      if details.line_hl_group then
        entry.line_hl_group = details.line_hl_group
        entry.line_colors = get_hl_colors(details.line_hl_group)
      end

      -- Sign
      if details.sign_text then
        entry.sign_text = details.sign_text
        entry.sign_hl = details.sign_hl_group
      end

      -- Categorize by markdown element
      local category = "other"
      if line_content:match("^######") then
        category = "h6"
      elseif line_content:match("^#####") then
        category = "h5"
      elseif line_content:match("^####") then
        category = "h4"
      elseif line_content:match("^###") then
        category = "h3"
      elseif line_content:match("^##") then
        category = "h2"
      elseif line_content:match("^#[^#]") then
        category = "h1"
      elseif line_content:match("^>") then
        category = "blockquote"
      elseif line_content:match("^%s*[-*]%s*%[.%]") then
        category = "task"
      elseif line_content:match("^%s*[-*+]%s") then
        category = "list_unordered"
      elseif line_content:match("^%s*%d+%.%s") then
        category = "list_ordered"
      elseif line_content:match("^```") then
        category = "code_fence"
      elseif line_content:match("`[^`]+`") then
        category = "inline_code"
      elseif line_content:match("^%-%-%-") or line_content:match("^%*%*%*") then
        category = "horizontal_rule"
      elseif line_content:match("^|") then
        category = "table"
      elseif line_content:match("%[.+%]%(") then
        category = "link"
      elseif line_content:match("^:.+") then
        category = "definition"
      elseif line_content:match("%*%*.+%*%*") or line_content:match("__.+__") then
        category = "strong"
      elseif line_content:match("%*.+%*") or line_content:match("_.+_") then
        category = "emphasis"
      elseif line_content:match("~~.+~~") then
        category = "strikethrough"
      end

      if entry.virt_text or entry.hl_group or entry.line_hl_group then
        add(category, entry)
      end
    end
  end

  -- Also capture treesitter highlights for key syntax elements
  local ts_captures = {}
  local ts_hl_map = {
    ["@markup.heading.1.markdown"] = "h1",
    ["@markup.heading.2.markdown"] = "h2",
    ["@markup.heading.3.markdown"] = "h3",
    ["@markup.heading.4.markdown"] = "h4",
    ["@markup.heading.5.markdown"] = "h5",
    ["@markup.heading.6.markdown"] = "h6",
    ["@markup.heading.markdown"] = "heading_generic",
    ["@markup.raw.markdown_inline"] = "inline_code",
    ["@markup.raw.block.markdown"] = "code_block",
    ["@markup.link.markdown"] = "link",
    ["@markup.link.label.markdown"] = "link_text",
    ["@markup.link.url.markdown"] = "link_url",
    ["@markup.list.markdown"] = "list_marker",
    ["@markup.list.checked.markdown"] = "task_checked",
    ["@markup.list.unchecked.markdown"] = "task_unchecked",
    ["@markup.quote.markdown"] = "blockquote",
    ["@markup.strong.markdown_inline"] = "strong",
    ["@markup.italic.markdown_inline"] = "emphasis",
    ["@markup.strikethrough.markdown_inline"] = "strikethrough",
    ["@punctuation.special.markdown"] = "punctuation",
  }

  for hl_name, category in pairs(ts_hl_map) do
    local colors = get_hl_colors(hl_name)
    if colors and (colors.fg or colors.bg) then
      ts_captures[category] = {
        hl_group = hl_name,
        colors = colors,
      }
    end
  end

  output.treesitter_highlights = ts_captures

  -- Capture render-markdown.nvim specific highlights
  local render_md_hls = {
    "RenderMarkdownH1",
    "RenderMarkdownH2",
    "RenderMarkdownH3",
    "RenderMarkdownH4",
    "RenderMarkdownH5",
    "RenderMarkdownH6",
    "RenderMarkdownH1Bg",
    "RenderMarkdownH2Bg",
    "RenderMarkdownH3Bg",
    "RenderMarkdownH4Bg",
    "RenderMarkdownH5Bg",
    "RenderMarkdownH6Bg",
    "RenderMarkdownCode",
    "RenderMarkdownCodeInline",
    "RenderMarkdownBullet",
    "RenderMarkdownQuote",
    "RenderMarkdownDash",
    "RenderMarkdownLink",
    "RenderMarkdownTableHead",
    "RenderMarkdownTableRow",
    "RenderMarkdownTableFill",
    "RenderMarkdownSuccess",
    "RenderMarkdownInfo",
    "RenderMarkdownHint",
    "RenderMarkdownWarn",
    "RenderMarkdownError",
    "RenderMarkdownUnchecked",
    "RenderMarkdownChecked",
  }

  output.render_markdown_highlights = {}
  for _, hl_name in ipairs(render_md_hls) do
    local colors = get_hl_colors(hl_name)
    if colors and (colors.fg or colors.bg) then
      output.render_markdown_highlights[hl_name] = colors
    end
  end
end

local function format_output()
  local lines = {}
  table.insert(lines, "=" .. string.rep("=", 70))
  table.insert(lines, "NEOVIM MARKDOWN RENDERING CAPTURE")
  table.insert(lines, "=" .. string.rep("=", 70))
  table.insert(lines, "")

  -- Render-markdown.nvim highlights (most important for glow theme)
  table.insert(lines, "## RENDER-MARKDOWN.NVIM HIGHLIGHT GROUPS")
  table.insert(lines, "-" .. string.rep("-", 50))
  if output.render_markdown_highlights then
    for name, colors in pairs(output.render_markdown_highlights) do
      local parts = { name .. ":" }
      if colors.fg then table.insert(parts, "fg=" .. colors.fg) end
      if colors.bg then table.insert(parts, "bg=" .. colors.bg) end
      if colors.bold then table.insert(parts, "bold") end
      if colors.italic then table.insert(parts, "italic") end
      if colors.underline then table.insert(parts, "underline") end
      table.insert(lines, "  " .. table.concat(parts, " "))
    end
  end
  table.insert(lines, "")

  -- Treesitter highlights
  table.insert(lines, "## TREESITTER HIGHLIGHTS")
  table.insert(lines, "-" .. string.rep("-", 50))
  if output.treesitter_highlights then
    for category, data in pairs(output.treesitter_highlights) do
      local parts = { category .. " (" .. data.hl_group .. "):" }
      if data.colors.fg then table.insert(parts, "fg=" .. data.colors.fg) end
      if data.colors.bg then table.insert(parts, "bg=" .. data.colors.bg) end
      if data.colors.bold then table.insert(parts, "bold") end
      if data.colors.italic then table.insert(parts, "italic") end
      table.insert(lines, "  " .. table.concat(parts, " "))
    end
  end
  table.insert(lines, "")

  -- Extmarks by category
  table.insert(lines, "## EXTMARKS BY ELEMENT TYPE")
  table.insert(lines, "-" .. string.rep("-", 50))

  local categories = {}
  for cat, _ in pairs(output) do
    if cat ~= "treesitter_highlights" and cat ~= "render_markdown_highlights" then
      table.insert(categories, cat)
    end
  end
  table.sort(categories)

  for _, category in ipairs(categories) do
    local entries = output[category]
    if type(entries) == "table" and #entries > 0 then
      table.insert(lines, "")
      table.insert(lines, "### " .. category:upper())

      -- Deduplicate by content
      local seen = {}
      for _, entry in ipairs(entries) do
        local key = ""

        if entry.virt_text then
          for _, vt in ipairs(entry.virt_text) do
            local icon_info = string.format("  ICON: '%s'", vt.text)
            if vt.hl_group then
              local hl_str = type(vt.hl_group) == "table" and vim.inspect(vt.hl_group) or tostring(vt.hl_group)
              icon_info = icon_info .. " hl=" .. hl_str
            end
            if vt.colors then
              if vt.colors.fg then icon_info = icon_info .. " fg=" .. vt.colors.fg end
              if vt.colors.bg then icon_info = icon_info .. " bg=" .. vt.colors.bg end
            end
            if not seen[icon_info] then
              table.insert(lines, icon_info)
              seen[icon_info] = true
            end
          end
        end

        if entry.hl_group then
          local hl_str = type(entry.hl_group) == "table" and vim.inspect(entry.hl_group) or tostring(entry.hl_group)
          if not seen[hl_str] then
            local hl_info = "  HL: " .. hl_str
            if entry.colors then
              if entry.colors.fg then hl_info = hl_info .. " fg=" .. entry.colors.fg end
              if entry.colors.bg then hl_info = hl_info .. " bg=" .. entry.colors.bg end
              if entry.colors.bold then hl_info = hl_info .. " bold" end
              if entry.colors.italic then hl_info = hl_info .. " italic" end
            end
            table.insert(lines, hl_info)
            seen[hl_str] = true
          end
        end

        if entry.line_hl_group then
          local line_hl_str = type(entry.line_hl_group) == "table" and vim.inspect(entry.line_hl_group) or tostring(entry.line_hl_group)
          if not seen["line_" .. line_hl_str] then
            local line_info = "  LINE_HL: " .. line_hl_str
            if entry.line_colors then
              if entry.line_colors.fg then line_info = line_info .. " fg=" .. entry.line_colors.fg end
              if entry.line_colors.bg then line_info = line_info .. " bg=" .. entry.line_colors.bg end
            end
            table.insert(lines, line_info)
            seen["line_" .. line_hl_str] = true
          end
        end
      end
    end
  end

  return table.concat(lines, "\n")
end

-- Main execution
local function main()
  -- Wait for buffer to be fully loaded and render-markdown to process
  vim.defer_fn(function()
    capture_buffer_highlights()
    local result = format_output()

    -- Write to file
    local out_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h") .. "/neovim-rendering.txt"
    local file = io.open(out_path, "w")
    if file then
      file:write(result)
      file:close()
      print("Captured to: " .. out_path)
    else
      -- Fallback: print to messages
      print(result)
    end
  end, 500) -- 500ms delay to let render-markdown.nvim process
end

main()
