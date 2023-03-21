-- command module
local Job = require("plenary.job")
local util = require("ruby_nvim.util")
local M = {}

local no_gem_in_cursor = "There is no gem close to the cursor"

-- :RubyBrowseGem
M.browse_gem = function()
  local node = util.get_method_relevant_to_cursor()
  if node == nil then
    vim.notify(no_gem_in_cursor, "error")
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  local gem_name = util.get_gem_name(node, bufnr)
  if gem_name == nil then
    vim.notify(no_gem_in_cursor, "error")
    return
  end

  local uri = "https://rubygems.org/gems/" .. gem_name

  Job:new({ "xdg-open", uri }):start()
end

return M
