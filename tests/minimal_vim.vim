let $plenary_dir = empty($PLENARY_DIR) ? '/tmp/plenary.nvim' : $PLENARY_DIR
if !isdirectory($plenary_dir)
  echom system(['git', 'clone', 'https://github.com/nvim-lua/plenary.nvim', $plenary_dir])
endif

set rtp+=.
set rtp+=$plenary_dir

runtime plugin/plenary.vim
runtime plugin/ruby.vim

lua require('plenary.busted')
