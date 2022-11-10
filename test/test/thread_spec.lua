local nm = require("notmuch.db")
local u = require("test/test/util")

local mid = "6391af02ba7ec4a76c5c5f462d8013fc1f52f999.1289789604.git.joe@perches.com"

local function get_thread(db, tmid)
  local message = db:find_message(tmid)
  local mtid = message:thread_id()
  local query = db:create_query("thread:" .. mtid)
  for thread in query:get_threads() do
    return thread
  end
end

local function collect(it)
  local box = {}

  for v in it do
    table.insert(box, v)
  end
  return box
end

describe("Threads", function ()
	it("Thread Id", function ()
		local maildir, db = u.create_db("tid")
    local message = u.insert_email(maildir, db)
    local thread = get_thread(db, message:id())

    assert.equal(thread:id(), '0000000000000001')
  end)
	it("Multi len", function ()
		local db = nm.db_open(nil, 0, nil, nil)
    local thread = get_thread(db, mid)

    assert.equal(thread:total_messages(), 100)
  end)
	it("Single len", function ()
		local maildir, db = u.create_db("tlen")
    local message = u.insert_email(maildir, db)
    local thread = get_thread(db, message:id())

    assert.equal(thread:total_messages(), 1)
  end)
	it("Toplevel", function ()
		local db = nm.db_open(nil, 0, nil, nil)
    local thread = get_thread(db, mid)
    for m in thread:toplevel_messages() do
    end
  end)
	it("Replies", function ()
		local db = nm.db_open(nil, 0, nil, nil)
    local thread = get_thread(db, mid)
    for m in thread:toplevel_messages() do
      for m2 in m:replies() do
      end
    end
  end)
	it("Authors", function ()
		local db = nm.db_open(nil, 0, nil, nil)
    local thread = get_thread(db, mid)
    local authors = thread:authors()

    assert.equal(authors, "Joe Perches, Jack Wang, Grant Likely, Michal Simek, Sjur BRENDELAND, Mel Gorman, Liam Girdwood, Mark Brown, Gregory V Rose, David Miller, Florian Mickler, Randy Dunlap, Joel Becker, Stefan Richter, Jiri Kosina, Pavel Machek, Artem Bityutskiy, Takashi Iwai, Matthew Garrett, Chris Ball")
  end)
end)
