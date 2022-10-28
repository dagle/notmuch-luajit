rockspec_format = "3.0"
package = 'notmuch'
version = 'main-0'
description = {
  detailed = "",
  homepage = "https://github.com/dagle/notmuch-lua",
  labels = { "notmuch", "binding", "luajit", "mail" },
  license = "MIT",
  summary = "luajit bindings for notmuch"
}
source = {
  url = 'git://github.com/dagle/notmuch-lua.git',
  tag = "main"
}
dependencies = {
  "lua = 5.1"
}
build = {
	type = "builtin",
	modules = {
		["lua.notmuch.db.lua"] = "lua/notmuch/db.lua",
		["lua.notmuch.init.lua"] = "lua/notmuch/init.lua",
		["lua.notmuch.util.lua"] = "lua/notmuch/util.lua",
		["lua.notmuch.thread.lua"] = "lua/notmuch/thread.lua",
		["lua.notmuch.query.lua"] = "lua/notmuch/query.lua",
		["lua.notmuch.message.lua"] = "lua/notmuch/message.lua",
		["lua.notmuch.directory.lua"] = "lua/notmuch/directory.lua",
		["lua.notmuch.conf.lua"] = "lua/notmuch/conf.lua",
	}
}
