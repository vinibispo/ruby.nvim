local ruby_cmd = require("ruby_nvim.cmd")
VIM_VERSION_MINOR_SUPPORTED = 7
if vim.version().minor < VIM_VERSION_MINOR_SUPPORTED then
  vim.notify("Sorry, but ruby.nvim doesn't support minors less than " .. VIM_VERSION_MINOR_SUPPORTED, "error")
  return
end

vim.api.nvim_create_user_command("RubyRun", function(opts)
  local arg
  if opts.fargs ~= '' then
    arg = opts.fargs[1]
  else
    arg = nil
  end
  ruby_cmd.run(arg)
end, { nargs = '?', complete = 'file' })

vim.api.nvim_create_user_command("RubyAlternate", function ()
  ruby_cmd.alternate()
end, { nargs = 0 })

vim.api.nvim_create_user_command("RubyTest", function (opts)
  ruby_cmd.test(opts.bang)
end, { bang = true })

vim.api.nvim_create_user_command("RubyBrowseGem", function ()
  ruby_cmd.browse_gem()
end, {nargs = 0 })


