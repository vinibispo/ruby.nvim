<div align="center">
<h1>ruby.nvim</h1>
Ruby development plug-in for Neovim. Highly unstable.
</div>

# Topics

:large_blue_diamond: [Motivation](#motivation)

:large_blue_diamond: [Installation](#installation)

:large_blue_diamond: [Setup](#setup)

:large_blue_diamond: [Commands](#commands)


# Motivation

This is a personal exercise on moving features from [go.nvim](https://github.com/ellisonleao/go.nvim) to the Ruby world, using latest features from Neovim. The idea is to try to use Lua as much as possible, without relying too much on Ruby 3rd party libraries. The focus is to push Lua the most we can.


# Installation

Use at least a neovim stable version.

Example with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'vinibispo/ruby.nvim',
  ft = {'ruby'}, -- optional
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter'
  }
}
```

Example with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'vinibispo/ruby.nvim'
```

# Setup

## Default config

Ruby.nvim comes with sane defaults so that you can get going without having to add much to your config

```lua
local ruby_nvim = require("ruby_nvim")

ruby_nvim.setup({
  test_cmd = "ruby" -- command that :RubyTest is gonna run,
  test_args = {} -- args that :RubyTest is gonna run
})
```


# Commands


| Command | Description |
|:--|:--|
| `:RubyRun [file]` | Runs `file` in a floating window (default: current file). |
| `:RubyAlternate` | Alternate between a Ruby file and its test file, and vice-versa |
| `:RubyTest[!]` | Runs the test for the current file. If the file is not a test file, it tries to find the (alternate) test file. If run with `!` and it is a test files, runs only the test under the cursor. |
| `:RubyBrowseGem` | Searches gem under the cursor line in [rubygems.org](https://rubygems.org). |
