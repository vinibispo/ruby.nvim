describe("setup", function()
  require("ruby_nvim")
end)

it("setup with default configs", function()
  local ruby_nvim = require("ruby_nvim")
  local defaults = { test_cmd = "ruby", test_args = {} }
  local opts = require("ruby_nvim.opts")

  ruby_nvim.setup({})

  assert.are.same(defaults.test_args, opts.load("test_args"))
  assert.equals(defaults.test_cmd, opts.load("test_cmd"))
end)

it("setup with custom configs", function()
  local ruby_nvim = require("ruby_nvim")
  local new_opts = { test_cmd = "rspec", test_args = { "--require 'spec_helper'" } }
  local opts = require("ruby_nvim.opts")

  ruby_nvim.setup(new_opts)

  assert.are.same(new_opts.test_args, opts.load("test_args"))
  assert.equals(new_opts.test_cmd, opts.load("test_cmd"))
end)
