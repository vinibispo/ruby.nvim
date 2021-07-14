-- command module
local Job = require('plenary.job')
local Path = require('plenary.path')
local window = require('plenary.window.float')
local util = require('ruby.util')
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

-- :RubyAlternate
M.alternate = function()
  local path = Path:new(vim.fn.expand('%'))
  if path:exists() ~= true or string.match(path.filename, '%.rb$') == nil then
    print('buffer is empty or file is not a ruby file')
    return
  end

  local alternates = {}
  local directories = {'app', 'lib'}
  local base_name = util.base_file_name(path)

  if string.match(path.filename, '_test%.rb$') ~= nil then
    local new_name, _ = string.gsub(base_name, '_test%.rb$', '.rb')
    for _, directory in pairs(directories) do
      table.insert(alternates, util.get_alternate(path, directory, new_name))
    end
  elseif string.match(path.filename, '_spec%.rb$') ~= nil then
    local new_name, _ = string.gsub(base_name, '_spec%.rb$', '.rb')
    for _, directory in pairs(directories) do
      table.insert(alternates, util.get_alternate(path, directory, new_name))
    end
  else
    for _, opts in pairs({{'_test.rb', 'test'}, {'_spec.rb', 'spec'}}) do
      local suffix = opts[1]
      local directory = opts[2]
      local new_name, _ = string.gsub(base_name, '%.rb$', suffix)
      table.insert(alternates, util.get_alternate(path, directory, new_name))
    end
  end

  for _, alternate in pairs(alternates) do
    if Path:new(alternate):exists() == true then
      vim.cmd('edit ' .. alternate)
      return
    end
  end

  vim.api.nvim_err_writeln('alternate file not found')
  return
end

return M
