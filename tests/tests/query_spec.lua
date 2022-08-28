local nm = require("notmuch.db")

local function collect_keys(t)
	local keys = {}
	for k, _ in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

local function equal(t1, t2)
	if #t1 ~= t2 then
		return false
	end
	table.sort(t1)
	table.sort(t2)
	for i, _ in ipairs(t1) do
		assert(t1[i] == t2[i])
	end
end

describe("Count a query", function ()
	it("count threads", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local query = db:create_query("tag:inbox")
		local num = query:count_threads()
		local i = 0
		for _ in query:get_threads() do
			i = i + 1
		end
		assert(num == i)
	end)
	it("count messages", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local query = db:create_query("tag:inbox")
		local num = query:count_messages()
		local i = 0
		for _ in query:get_messages() do
			i = i + 1
		end
		assert(num == i)
	end)
	it("collect tags", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local tags = {}

		local query = db:create_query("tag:inbox")
		for tag in query:collect_tags() do
			tags.insert(tags, tag)
		end
		local mtags = {}
		for message in query:get_messages() do
			for tag in message:get_tags() do
				mtags[tag] = true
			end
		end
		local mcollect = collect_keys(mtags)
		assert(equal(tags, mcollect))
	end)
	it("sort", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local query = db:create_query("tag:inbox")
		local sort = "newest"
		query:set_sort(sort)
		assert(sort == query:get_sort())
	end)
end)
