local opts = require("ruby_nvim.opts")
local M = {}

M.setup = function(user_options)
  opts.configure(user_options)
end

return M
