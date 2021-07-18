local cmd = vim.cmd
cmd([[command! -nargs=1 -complete=file RubyRun lua require("ruby_nvim.cmd").run(<f-args>)]])
cmd([[command! RubyAlternate lua require("ruby_nvim.cmd").alternate()]])
cmd([[command! -bang RubyTest lua require("ruby_nvim.cmd").test("<bang>")]])
