local nm = require("notmuch.db")

describe("Message getters", function ()
	local db = nm.db_open(nil, 0, nil, nil)
	--- TODO a real query
	local query = db:create_query("tag:inbox")
	for message in query:get_messages() do
		message:id()
		message:thread_id()
		message:replies()
		message:count_files()
		message:filename()
		message:filenames()
		message:count_files()
	end
end)

describe("Message add and remove tag", function ()
	it("Add tag", function ()
		local db = nm.db_open(nil, 1, nil, nil)
		local query = db:create_query("tag:inbox")
		for message in query:get_messages() do
			message:add_tag("testtag")
		end
	end)
	it("Read tags", function ()
		local db = nm.db_open(nil, 1, nil, nil)
		local query = db:create_query("tag:inbox")
		for message in query:get_messages() do
			local found = false
			for tag in message:get_tags() do
				if tag == "testtag" then
					found = true
				end
			end
			assert(found)
		end
	end)
	it("Remove tag", function ()
		local db = nm.db_open(nil, 1, nil, nil)
		local query = db:create_query("tag:inbox")
		for message in query:get_messages() do
			message:remove_tag("testtag")
		end
	end)
	it("Read tags again", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local query = db:create_query("tag:inbox")
		for message in query:get_messages() do
			local found = false
			for tag in message:get_tags() do
				if tag == "testtag" then
					found = true
				end
			end
			assert(not found)
		end
	end)

	describe("Change special tags", function ()
		-- test freeze/thaw
		-- test writing back messages to db
		-- sync maildirs
		-- filename should be updated
	end)
end)
