-- command module
local Job = require('plenary.job')
local window = require('plenary.window.float')
local api = vim.api
local fn = vim.fn
local schedule_wrap = vim.schedule_wrap
local M = {}

-- :RubyRun
M.run = function(file)
  local win = window.percentage_range_window(tonumber("0.8"), tonumber("0.8"))
  local job_id = api.nvim_open_term(win.bufnr, {})
  Job:new{
    "ruby",
    fn.expand(file),
    on_stdout = schedule_wrap(function(_, data)
      api.nvim_chan_send(job_id, data .. "\r\n")
    end),
    on_stderr = schedule_wrap(function(_, data)
      api.nvim_chan_send(job_id, data .. "\r\n")
    end),
  }:start()
end

return M
