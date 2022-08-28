local nm = require("notmuch.db")

describe("Directory functions", function ()
	it("mtime", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local path = "" -- read a path from the db
		local dir = db:get_directory(path)
		local time
		dir:set_mtime(time)
		assert(time == dir:get_mtime(time))
	end)

	it("child files", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local path = "" -- read a path from the db
		local dir = db:get_directory(path)
		for file in dir:get_child_files() do
			--- do stuff
		end
	end)

	it("child directory", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local path = "" -- read a path from the db
		local dir = db:get_directory(path)
		for file in dir:get_child_directories() do
			--- do stuff
		end
	end)
end)
