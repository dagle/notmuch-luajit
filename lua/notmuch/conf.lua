local nm = require "notmuch"

local M = {}

function M:new(db)
  local this = {
    db = db
  }
  self.__index = function(tbl, key)
    return nm.db_get_conf(tbl.db, key)
  end
  self.__newindex = function(tbl, key, value)
    nm.db_set_conf(tbl.db, key, value)
  end

  --- not in lua 5.1
  -- self.__ipairs = function(_)
  --   return nm.db_get_conf_list(db, "")
  -- end
  setmetatable(this, self)

  return this
end

return M
