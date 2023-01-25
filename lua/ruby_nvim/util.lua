-- util functions
local M = {}

-- local functions
local function get_methods(root)
  local keys = {}
  for node, name in root:iter_children() do
    if name == "method" then
      table.insert(keys, node)
    end

    if node:child_count() > 0 then
      for _, child in pairs(get_methods(node)) do
        table.insert(keys, child)
      end
    end
  end
  return keys
end

local all_methods = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, "ft")
  local tree = vim.treesitter.get_parser(bufnr, ft):parse()[1]
  local root = tree:root()
  return get_methods(root)
end

-- public functions
M.get_gem_name = function(node, bufnr)
  while node ~= nil do
    if node:type() == "call" then
      local method = node:field("method")[1]
      local method_name = vim.treesitter.query.get_node_text(method, bufnr)
      if method_name == "gem" then
        local method_args = node:field("arguments")[1] --that has user_data { 'aws-sdk-s3', '~> 1' }
        local gem_node_with_quotes = method_args:child(0) -- that has user_data { "'", "aws-sdk-s3", "'" }
        if gem_node_with_quotes:child_count() > 2 then
          local gem_node = gem_node_with_quotes:child(1) -- that  has user_data { "aws-sdk-s3" }
          local gem_name = vim.treesitter.query.get_node_text(gem_node, bufnr)
          return gem_name
        end
      end
    end
    node = node:parent()
  end
end

M.get_method_relevant_to_cursor = function()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local previous_node = nil
  for _, node in pairs(all_methods()) do
    local node_line, _ = node:start()
    node_line = node_line + 1
    if cursor_line == node_line then
      return node
    end

    if cursor_line < node_line then
      return previous_node
    end

    previous_node = node
  end
end

return M
