local nm = require("notmuch.db")

describe("Thread getters", function ()
	local db = nm.db_open(nil, 0, nil, nil)
	--- TODO a real query
	local query = db:create_query("tag:inbox")
	for thread in query:get_threads() do
		thread:total_messages()
		thread:total_files()
	end
end)

describe("Thread walk tree", function ()
end)
