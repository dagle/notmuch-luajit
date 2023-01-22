local nm = require("notmuch2")

local db = nm.db_open_with_config(nil, 0)
local q = db:create_query("apa")

for mes in q:get_messages() do
  -- print(mes:get_id())
  -- break
end
-- print(q:get_string())
-- print(q:count_threads())
db = nil;
