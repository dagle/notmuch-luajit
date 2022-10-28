local nm = require "notmuch"

local M = {}

function M:new(db)
  local this = {}
  self.__index = function(_, key)
    return nm.db_get_conf(db, key)
  end
  self.__newindex = function(_, key, value)
    nm.db_set_config(db, key, value)
  end

  --- not in lua 5.1
  self.__ipairs = function(_)
    return nm.db_get_conf_list(db, "")
  end
  setmetatable(this, self)

  return this
end

return M
