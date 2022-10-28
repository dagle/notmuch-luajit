require 'busted.runner'()
local nm = require("notmuch.db")

local function collect_keys(t)
	local keys = {}
	for k, _ in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

local function equal(t1, t2)
	for k, _ in pairs(t1) do
		if t1[k] ~= t2[k] then
			return false
		end
	end
	for k, _ in pairs(t2) do
		if t1[k] ~= t2[k] then
			return false
		end
	end
	return true
end

describe("Count a query", function ()
	local db = nm.db_open(nil, 0, nil, nil)
	it("count threads", function ()
		local query = db:create_query("tag:inbox")
		local num = query:count_threads()
		local i = 0
		for _ in query:get_threads() do
			i = i + 1
		end
		assert(num == i, string.format("Values not equal: %d - %d", num, i))
	end)
	-- it("count messages", function ()
	-- 	local query = db:create_query("tag:inbox")
	-- 	local num = query:count_messages()
	-- 	local i = 0
	-- 	for _ in query:get_messages() do
	-- 		i = i + 1
	-- 	end
	-- 	assert(num == i, string.format("Values not equal: %d - %d", num, i))
	-- end)
	-- it("collect tags", function ()
	-- 	local tags = {}
	--
	-- 	local query = db:create_query("tag:inbox")
	-- 	for tag in query:collect_tags() do
	-- 		tags[tag] = true
	-- 	end
	-- 	local mtags = {}
	-- 	for message in query:get_messages() do
	-- 		for tag in message:get_tags() do
	-- 			mtags[tag] = true
	-- 		end
	-- 	end
	-- 	assert(equal(tags, mtags))
	-- end)
	-- it("sort", function ()
	-- 	local db = nm.db_open(nil, 0, nil, nil)
	-- 	local query = db:create_query("tag:inbox")
	-- 	local sort = "newest"
	-- 	query:set_sort(sort)
	-- 	assert(sort == query:get_sort())
	-- end)
end)
