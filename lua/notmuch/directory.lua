local nm = require "notmuch"

local M = {}
function M:new(directory)
  local this = {
    directory = directory,
  }
  self.__index = self
  setmetatable(this, self)

  return this
end

function M:set_mtime(time)
  nm.directory_set_mtime(self.directory, time)
end

function M:get_mtime()
  return nm.directory_get_mtime(self.directory)
end

function M:get_child_files()
  return nm.directry_get_child_files(self.directory)
end

function M:get_child_directories()
  return nm.directory_get_child_directories(self.directory)
end

function M:delete()
  return nm.directory_delete(self.directory)
end

return M
