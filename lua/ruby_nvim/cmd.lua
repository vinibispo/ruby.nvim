-- command module
local Job = require("plenary.job")
local Path = require("plenary.path")
local window = require("plenary.window.float")
local opts = require("ruby_nvim.opts")
local util = require("ruby_nvim.util")
local api = vim.api
local fn = vim.fn
local schedule_wrap = vim.schedule_wrap
local M = {}

local no_file_or_not_rb_file = "buffer is empty or file is not a ruby file"
local no_gem_in_cursor = "There is no gem close to the cursor"

local run_in_floating_window = function(cmd, args)
  local win = window.percentage_range_window(tonumber("0.8"), tonumber("0.8"))
  local job_id = api.nvim_open_term(win.bufnr, {})

  Job:new({
    command = cmd,
    args = args,
    on_stdout = schedule_wrap(function(_, data)
      api.nvim_chan_send(job_id, data .. "\r\n")
    end),
    on_stderr = schedule_wrap(function(_, data)
      api.nvim_chan_send(job_id, data .. "\r\n")
    end),
  }):start()
end

-- :RubyRun
M.run = function(file)
  vim.notify("The command :RubyRun is deprecated in favor of :term ruby %", "warn")
  file = file or fn.expand("%")
  run_in_floating_window("ruby", { fn.expand(file) })
end

-- :RubyAlternate
M.alternate = function()
  vim.notify("The command :RubyTest is deprecated in favor of rgroli/other.nvim", "warn")
  local path = Path:new(vim.fn.expand("%"))
  if not path:exists() or not util.is_ruby(path) then
    vim.notify(no_file_or_not_rb_file, "warn")
    return
  end

  local alternate = util.alternate(path)
  if alternate == nil then
    vim.notify("could not find an alternate file", "warn")
    return
  end

  vim.cmd("edit " .. alternate.filename)
end

-- :RubyTest
M.test = function(current_line)
  vim.notify("The command :RubyTest is deprecated in favor of nvim-neotest/neotest", "warn")
  local current_line = current_line == "!"
  local path = Path:new(vim.fn.expand("%"))

  if not util.is_ruby(path) then
    vim.notify(no_file_or_not_rb_file, "warn")
    return
  end

  if not util.is_test(path) then
    if current_line then
      vim.notify("not in a test file", "error")
      return
    else
      path = util.alternate(path)
    end
  end

  if not path then
    vim.notify("could not find a test file", "warn")
    return
  end

  local args = vim.deepcopy(opts.load("test_args"))
  table.insert(args, fn.expand(path.filename))
  if current_line then
    args[#args] = args[#args] .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
  end

  run_in_floating_window(opts.load("test_cmd"), args)
end

-- :RubyBrowseGem
M.browse_gem = function()
  local node = util.get_method_relevant_to_cursor()
  if node == nil then
    vim.notify(no_gem_in_cursor, "error")
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  local gem_name = util.get_gem_name(node, bufnr)
  if gem_name == nil then
    vim.notify(no_gem_in_cursor, "error")
    return
  end

  local uri = "https://rubygems.org/gems/" .. gem_name

  Job:new({ "xdg-open", uri }):start()
end

return M
