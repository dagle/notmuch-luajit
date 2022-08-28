local nm = require("notmuch")
local message = require("notmuch.message")
local u = require("notmuch.util")

local M = {}
function M:new(thread)
	local this = {
		thread = thread
	}
	self.__index = self
	setmetatable(this, self)

	return this
end

function M:id()
	return nm.thread_get_id(self.thread)
end

function M:total_messages()
	return nm.thread_get_total_messages(self.thread)
end

function M:total_files()
	return nm.thread_get_total_files(self.thread)
end

function M:toplevel_messages()
	return u.wrap_iterator(nm.thread_get_toplevel_messages(self.thread), message)
end

function M:get_messages()
	return u.wrap_iterator(nm.thread_get_messages(self.thread), message)
end

function M:matched_messages()
	return u.wrap_iterator(nm.thread_get_matched_messages(self.thread), message)
end

function M:authors()
	return nm.thread_get_authors(self.thread)
end

function M:oldest_date()
	return nm.thread_get_oldest_date(self.thread)
end

function M:newest_date()
	return nm.thread_get_newest_date(self.thread)
end

function M:tags()
	return nm.thread_get_tags(self.thread)
end

return M
