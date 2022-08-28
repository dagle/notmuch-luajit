local nm = require("notmuch")
local u = require("notmuch.util")

local M = {}
function M:new(messsage)
	local this = {
		message = messsage
	}
	self.__index = self
	setmetatable(this, self)

	return this
end

function M:get_db()
	--- TODO
end

function M:id()
	return nm.message_get_id(self.message)
end

function M:thread_id()
	return nm.message_get_thread_id(self.message)
end

function M:replies()
	return u.wrap_iterator(nm.message_get_replies(self.message), M)
end

function M:count_files()
	return nm.message_count_files(self.message)
end

function M:filename()
	return nm.message_get_filename(self.message)
end

function M:filenames()
	return nm.message_get_filenames(self.message)
end

function M:reindex(opts)
	return nm.message_reindex(self.message, opts)
end

function M:get_flag(flag)
	return nm.message_get_flag(self.message, flag)
end

function M:set_flags(flag, value)
	return nm.message_set_flag(self.message, flag, value)
end

function M:get_header(header)
	return nm.message_get_header(self.message, header)
end

function M:get_tags()
	return nm.message_get_tags(self.message)
end

function M:add_tag(tag)
	return nm.message_add_tag(self.message,tag)
end

function M:remove_tag(tag)
	return nm.message_remove_tag(self.message, tag)
end

function M:remove_all_tags()
	return nm.message_remove_all_tags(self.message)
end

function M:flags_to_tags()
	return nm.message_maildir_flags_to_tags(self.message)
end

function M:has_maildir_flag(flag)
	return nm.message_has_maildir_flag(self.message, flag)
end

function M:tags_to_flags()
	return nm.message_tags_to_maildir_flags(self.message)
end

function M:freeze()
	return nm.message_freeze(self.message)
end

function M:thaw()
	return nm.message_thaw(self.message)
end

function M:add_property(key, value)
	return nm.message_add_property(self.message, key, value)
end

function M:remove_property(key, value)
	return nm.message_remove_properety(self.message, key, value)
end

function M:remove_all_properties(key)
	return nm.message_remove_all_properties(self.message, key)
end

function M:remove_all_properties_with_prefix(prefix)
	return nm.message_remove_all_properties_with_prefix(self.message, prefix)
end

function M:get_properties(key, exact)
	return nm.message_get_properties(self.message, key, exact)
end

function M:count_properties(key)
	return nm.message_count_properties(self.message, key)
end

return M
