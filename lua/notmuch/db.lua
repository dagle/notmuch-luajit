local nm = require("notmuch")
local c = require("notmuch.conf")
local query = require("notmuch.query")
local directory = require("notmuch.directory")
local message = require("notmuch.message")

local M = {}
function M:new(db)
	local this = {
		db = db,
		conf = c:new()
	}
	self.__index = self
	setmetatable(this, self)

	return this
end

function M.db_open(path, mode, conf, profile)
	return M:new(nm.db_open_with_config(path, mode, conf, profile))
end

function M.db_create(path, mode, conf, profile)
	return M:new(nm.db_create_with_config(path, mode, conf, profile))
end

function M.db_load(path, conf, profile)
	return M:new(nm.db_load_config(path, conf, profile))
end

function M:get_path()
	return nm.db_get_path(self.db)
end

function M:get_version()
	return nm.db_get_version(self.db)
end

function M:needs_upgrade()
	return nm.db_needs_upgrade(self.db)
end

function M:upgrade(func, arg)
	return nm.db_upgrade(self.db, func, arg)
end

function M:atomic_begin()
	return nm.db_atomic_begin(self.db)
end

function M:atomic_end()
	return nm.db_atomic_end(self.db)
end

function M:get_revision()
	return nm.get_revision(self.db)
end

function M:get_directory(path)
	return directory:new(nm.db_get_directory(self, path))
end

function M:index_file(filename, opts)
	return nm.db_index_file(self.db, filename, opts)
end

function M:remove_message(filename)
	return nm.db_remove_message(self.db, filename)
end

function M:find_message(mid)
	return message:new(nm.db_find_message(self.db, mid))
end

function M:find_message_by_filename(filename)
	return message:new(nm.db_find_message_by_filename(self.db, filename))
end

function M:get_all_tags()
	return nm.db_get_all_tags(self.db)
end

function M:repon(mode)
	return nm.db_reopen(self.db, mode)
end

function M:create_query(str)
	return query.new(nm.create_query(self.db, str))
end

function M:create_query_with_syntax(str, syntax)
	return query.new(nm.create_query_with_syntax(self.db, str, syntax))
end

return M
