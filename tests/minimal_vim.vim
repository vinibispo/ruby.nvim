set rtp+=.
set rtp+=vendor/plenary.nvim

runtime plugin/plenary.vim
runtime plugin/ruby.vim

lua require('plenary.busted')
