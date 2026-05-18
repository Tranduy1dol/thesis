-- Lua filter: convert tables to raw LaTeX tabular (no longtable)
-- Required for IEEE 2-column format

local function escape_latex(s)
  return s
end

local function align_char(align)
  if align == "AlignLeft" then return "l"
  elseif align == "AlignRight" then return "r"
  elseif align == "AlignCenter" then return "c"
  else return "l"
  end
end

local function inlines_to_latex(inlines)
  return pandoc.write(pandoc.Pandoc({pandoc.Plain(inlines)}), "latex")
end

local function blocks_to_latex(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "latex")
end

local function cells_to_latex(cells)
  local result = {}
  for i, cell in ipairs(cells) do
    local content = blocks_to_latex(cell.contents)
    content = content:gsub("\n$", "")
    table.insert(result, content)
  end
  return table.concat(result, " & ")
end

function Table(tbl)
  local caption_text = ""
  if tbl.caption and tbl.caption.long and #tbl.caption.long > 0 then
    caption_text = blocks_to_latex(tbl.caption.long)
    caption_text = caption_text:gsub("\n$", "")
  end

  -- Build column spec
  local cols = {}
  for i, spec in ipairs(tbl.colspecs) do
    table.insert(cols, align_char(spec[1]))
  end
  local colspec = table.concat(cols, "")

  local lines = {}
  table.insert(lines, "\\begin{table}[t]")
  table.insert(lines, "\\centering")
  if caption_text ~= "" then
    table.insert(lines, "\\caption{" .. caption_text .. "}")
  end
  table.insert(lines, "\\begin{tabular}{" .. colspec .. "}")
  table.insert(lines, "\\toprule")

  -- Header
  if tbl.head and tbl.head.rows and #tbl.head.rows > 0 then
    for _, row in ipairs(tbl.head.rows) do
      local row_latex = cells_to_latex(row.cells)
      table.insert(lines, row_latex .. " \\\\")
    end
    table.insert(lines, "\\midrule")
  end

  -- Body
  for _, body in ipairs(tbl.bodies) do
    for _, row in ipairs(body.body) do
      local row_latex = cells_to_latex(row.cells)
      table.insert(lines, row_latex .. " \\\\")
    end
  end

  table.insert(lines, "\\bottomrule")
  table.insert(lines, "\\end{tabular}")
  table.insert(lines, "\\end{table}")

  return pandoc.RawBlock("latex", table.concat(lines, "\n"))
end
