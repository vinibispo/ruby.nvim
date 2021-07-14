-- util functions
local Job = require("plenary.job")
local Path = require("plenary.path")
local M = {}

local git_root = function(file)
  local path = Path:new(file)
  if path:exists() ~= true then
    return nil
  end

  local opts = {
    command = "git",
    args = {"rev-parse", "--show-toplevel"},
    cwd = path:parent(),
  }
  local job = Job:new(opts):sync()
  if job == nil then
    print("git noit installed or not in a git repository")
    return nil
  end

  return job[1]
end

local split_path = function(path)
  local matches = {}
  for match in (path .. Path.path.sep):gmatch("(.-)" .. Path.path.sep) do
    table.insert(matches, match)
  end
  return matches
end

M.base_file_name = function(file_path)
    local path = Path:new(file_path)
    local parts = split_path(path)
    return parts[#parts]
end

M.get_alternate = function(file_path, alternate_directory, alternate_name)
  local git = git_root(file_path)
  local path = Path:new(file_path):make_relative(git)
  local parts = split_path(path)

  parts[1] = alternate_directory
  parts[#parts] = alternate_name
  local alternate = Path:new(git):joinpath(unpack(parts))

  if alternate:exists() ~= true then
    return nil
  end

  return alternate.filename
end

return M
