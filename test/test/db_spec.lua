require 'busted.runner'()

-- local nm = require("lua.notmuch.db")
local nm = require("notmuch.db")
local filename = ""
describe("Db tests", function ()
	it("Open db", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		db = nil
	end)

	-- it("open db writable", function ()
	-- 	local db = nm.db_open(nil, 1, nil, nil)
	-- 	db = nil
	-- end)
	--
	-- it("index file", function ()
	-- 	local db = nm.db_open(nil, 1, nil, nil)
	-- 	db:index_file(filename)
	-- end)
	--
	-- it("find message by filename", function ()
	-- 	local db = nm.db_open(nil, 0, nil, nil)
	-- 	local message = db:find_message(filename)
	-- 	assert(filename == message:filename())
	-- end)
	--
	-- it("remove message", function ()
	-- 	local db = nm.db_open(nil, 1, nil, nil)
	-- 	db:remove_message(filename)
	-- 	-- try to get an error finding the file
	-- end)
	--
	-- it("remove message", function ()
	-- 	local db = nm.db_open(nil, 1, nil, nil)
	-- end)
	--
	-- it("get all tags", function ()
	-- 	local db = nm.db_open(nil, 0, nil, nil)
	-- end)
	--
	-- it("reopen and try to write", function ()
	-- 	local db = nm.db_open(nil, 0, nil, nil)
	-- 	-- try to do a write, it should fail
	-- 	db:reopen(1)
	-- 	-- try to do a write, again!
	-- end)
	--
	it("create_query", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		db:create_query("*")
		-- this should free everything
		db = nil
	end)
	--
	-- -- TODO 
	-- -- atomic testing/add with_atomic?
	--
	-- it("test cleanup", function ()
	-- 	-- ?
	-- end)
end)
