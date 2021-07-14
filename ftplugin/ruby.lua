local cmd = vim.cmd
cmd([[command! -nargs=1 -complete=file RubyRun lua require("ruby.cmd").run(<f-args>)]])
cmd([[command! RubyAlternate lua require("ruby.cmd").alternate()]])
