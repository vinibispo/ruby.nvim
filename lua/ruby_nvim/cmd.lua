-- command module
local Job = require("plenary.job")
local Path = require("plenary.path")
local window = require("plenary.window.float")
local ruby = require("ruby_nvim")
local opts = require("ruby_nvim.opts")
local util = require("ruby_nvim.util")
local api = vim.api
local fn = vim.fn
local schedule_wrap = vim.schedule_wrap
local M = {}

local no_file_or_not_rb_file = "buffer is empty or file is not a ruby file"

local run_in_floating_window = function(cmd, args)
  local win = window.percentage_range_window(tonumber("0.8"), tonumber("0.8"))
  local job_id = api.nvim_open_term(win.bufnr, {})

  Job:new(
    {
      command = cmd,
      args = args,
      on_stdout = schedule_wrap(
        function(_, data)
          api.nvim_chan_send(job_id, data .. "\r\n")
        end
      ),
      on_stderr = schedule_wrap(
        function(_, data)
          api.nvim_chan_send(job_id, data .. "\r\n")
        end
      ),
    }
  ):start()
end

-- :RubyRun
M.run = function(file)
  run_in_floating_window("ruby", {fn.expand(file)})
end

-- :RubyAlternate
M.alternate = function()
  local path = Path:new(vim.fn.expand("%"))
  if not path:exists() or not util.is_ruby(path) then
    print("buffer is empty or file is not a ruby file")
    return
  end

  local alternate = util.alternate(path)
  if not alternate:exists() then
    print("could not find an alternate file")
    return
  end

  vim.cmd("edit " .. alternate.filename)
end

-- :RubyTest
M.test = function(current_line)
  local current_line = current_line == "!"
  local path = Path:new(vim.fn.expand("%"))

  if not util.is_ruby(path) then
    print(no_file_or_not_rb_file)
    return
  end

  if not util.is_test(path) then
    if current_line then
      print("not in a test file")
      return
    else
      path = util.alternate(path)
    end
  end

  if not path then
    print("could not find a test file")
    return
  end

  local args = vim.deepcopy(opts.load("test_args"))
  table.insert(args, fn.expand(path.filename))
  if current_line then
    args[#args] = args[#args] .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
  end

  run_in_floating_window(opts.load("test_cmd"), args)
end

return M
