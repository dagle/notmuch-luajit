local nm = require("notmuch")
local message = require("notmuch.message")
local thread = require("notmuch.thread")
local u = require("notmuch.util")

local M = {}
function M:new(query)
	local this = {
		query = query
	}
	self.__index = self
	setmetatable(this, self)

	return this
end

function M:get_string()
	return nm.query_get_string(self.query)
end

-- function M:get_db()
	--- TODO, this doesn't return a db class object
	-- return nm.query_get_db(self.query)
-- end

function M:set_omit(exclude)
	return nm.set_omit(self.query, exclude)
end

function M:set_sort(sort)
	nm.query_set_sort(self.query, sort)
end

function M:get_sort()
	return nm.query_get_sort(self.query)
end

function M:tag_exclude(tag)
	return nm.query_add_tag_exclude(self.query, tag)
end

function M:get_threads()
	return u.wrap_iterator(nm.query_get_threads(self.query), thread)
end


function M:get_messages()
	return u.wrap_iterator(nm.query_get_messages(self.query), message)
end

function M:count_threads()
	return nm.query_count_threads(self.query)
end

function M:count_messages()
	return nm.query_count_messages(self.query)
end

function M:collect_tags()
	return nm.messages_collect_tags(self.query)
end

return M
