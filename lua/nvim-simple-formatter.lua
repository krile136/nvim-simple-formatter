local M = {}

M.getFullBufferText = function(bufnr)
  local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0 -1, true), "\n")
  if vim.api.nvim_buf_get_option(bufnr, "eol") then
    text = text .. "\n"
  end
  return text
end

M.formatBuffer = function(cmd)
  local bufnr = vim.fn.bufnr("%")
  local input = M.getFullBufferText(bufnr)
  local output = vim.fn.system(cmd, buffer_text)
  if output ~= input then
    local new_lines = vim.fn.split(output, "\n")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
  end
end

M.createFormatFunction = function(cmd)
  return function()
    M.formatBuffer(cmd)
  end
end

M.setup = function(options)
  M.options = vim.tbl_deep_extend("force", {}, M.options, options or {})
  for _, rule in ipairs(options.format_rules) do
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      pattern = rule.pattern,
      callback = M.createFormatFunction(rule.command)
    })
  end
end
