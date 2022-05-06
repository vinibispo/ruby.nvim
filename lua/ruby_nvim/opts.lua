local defaults = { test_cmd = "ruby", test_args = {} }
local options = vim.deepcopy(defaults)
local M = {}

M.configure = function(user_options)
  options = vim.tbl_extend("force", options, user_options)
end

M.load = function(key)
  return options[key]
end

return M
