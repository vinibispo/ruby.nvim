local cmd = vim.cmd
cmd(
  [[command! -nargs=? -complete=file RubyRun lua require("ruby_nvim.cmd").run(<f-args>)]])
cmd([[command! RubyAlternate lua require("ruby_nvim.cmd").alternate()]])
cmd([[command! -bang RubyTest lua require("ruby_nvim.cmd").test("<bang>")]])
cmd([[command! -nargs=0 RubyBrowseGem lua require('ruby_nvim.cmd').browse_gem()]])
