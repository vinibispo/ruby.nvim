-- util functions
local Job = require("plenary.job")
local Path = require("plenary.path")
local M = {}

-- local functions
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

local base_file_name = function(file_path)
  local path = Path:new(file_path)
  local parts = split_path(path)
  return parts[#parts]
end

local get_alternate = function(file_path, alternate_directory, alternate_name)
  local git = git_root(file_path)
  local path = Path:new(file_path):make_relative(git)
  local parts = split_path(path)

  parts[1] = alternate_directory
  parts[#parts] = alternate_name
  local alternate = Path:new(git):joinpath(unpack(parts))

  if not alternate:exists() then
    return nil
  end

  return alternate
end

-- public functions
M.is_ruby = function(path)
  return path:exists() and string.match(path.filename, "%.rb$")
end

M.is_test = function(path)
  return string.match(path.filename, "_test%.rb$") or
           string.match(path.filename, "_spec%.rb$")
end

M.alternate = function(path)
  local alternates = {}
  local directories = {"app", "lib"}
  local base_name = base_file_name(path)

  if string.match(path.filename, "_test%.rb$") then
    local alternate, _ = string.gsub(base_name, "_test%.rb$", ".rb")
    for _, directory in pairs(directories) do
      table.insert(alternates, get_alternate(path, directory, alternate))
    end
  elseif string.match(path.filename, "_spec%.rb$") then
    local alternate, _ = string.gsub(base_name, "_spec%.rb$", ".rb")
    for _, directory in pairs(directories) do
      table.insert(alternates, get_alternate(path, directory, alternate))
    end
  else
    for _, opts in pairs({{"_test.rb", "test"}, {"_spec.rb", "spec"}}) do
      local suffix = opts[1]
      local directory = opts[2]
      local new_name, _ = string.gsub(base_name, "%.rb$", suffix)
      table.insert(alternates, get_alternate(path, directory, new_name))
    end
  end

  for _, alternate in pairs(alternates) do
    if alternate:exists() then
      return alternate
    end
  end
end

return M
