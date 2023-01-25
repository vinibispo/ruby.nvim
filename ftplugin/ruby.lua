local ruby_cmd = require("ruby_nvim.cmd")
VIM_VERSION_MINOR_SUPPORTED = 7
if vim.version().minor < VIM_VERSION_MINOR_SUPPORTED then
  vim.notify("Sorry, but ruby.nvim doesn't support minors less than " .. VIM_VERSION_MINOR_SUPPORTED, "error")
  return
end

vim.api.nvim_create_user_command("RubyBrowseGem", function()
  ruby_cmd.browse_gem()
end, { nargs = 0 })
