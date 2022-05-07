# ruby.nvim

Ruby development plug-in for Neovim. Highly unstable.

# Motivation

This is a personal exercise on moving features from [go.nvim](https://github.com/ellisonleao/go.nvim) to the Ruby world, using latest features from Neovim. The idea is to try to use Lua as much as possible, without relying too much on Ruby 3rd party libraries. The focus is to push Lua the most we can.

Example with [packer.nvim](https://github.com/wbthomason/packer.nvim/):

```lua
use {
  'vinibispo/ruby.nvim',
  ft = {'ruby'}, -- optional
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter'
    },
  config = function() -- optional
    require("ruby_nvim").setup({
      test_cmd = "ruby",  -- the default value
      test_args = {},  -- the default value
    })
  end,
}
```

# Disclaimer

That is totally based on [go.nvim](https://github.com/npxbr/go.nvim).
