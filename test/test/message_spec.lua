local nm = require("notmuch.db")
local u = require("test/test/util")

local mid = "6391af02ba7ec4a76c5c5f462d8013fc1f52f999.1289789604.git.joe@perches.com"
local filename = vim.fn.getcwd() .. "/test/testdir/testdata/testmail/lkml/cur/1382298793.002259:2,"
local multifile = "6391af02ba7ec4a76c5c5f462d8013fc1f52f999.1289789604.git.joe@perches.com"

describe("Messages", function ()
	it("Add message", function ()
		local maildir, db = u.create_db("madd")
    local _ = u.insert_email(maildir, db)
  end)

	it("Message id", function ()
		local db = nm.db_open(nil, 0, nil, nil)

    local message = db:find_message(mid)
    assert.equal(message:id(), mid)
  end)
	it("find file by id", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local message = db:find_message(mid)
		assert.equal(filename, message:filename())
	end)
	it("find message by file", function ()
		local db = nm.db_open(nil, 0, nil, nil)
		local message = db:find_message_by_filename(filename)
		assert.equal(mid, message:id())
	end)
  it("Thread id", function ()
		local maildir, db = u.create_db("mtid")
    local message = u.insert_email(maildir, db)

    assert.equal(message:thread_id(), '0000000000000001')
  end)
  it("One file", function ()
		local db = nm.db_open(nil, 0, nil, nil)
    local message = db:find_message(mid)
    local num = 0
    for _ in message:filenames() do
      num = num + 1
    end

    assert.equal(num, 1)
  end)
--   it("Multifiles", function ()
-- 		local db = nm.db_open(nil, 0, nil, nil)
--     local message = db:find_message(multifile)
--
--     assert.equal(#message:filenames(), 2)
--   end)
end)

-- TODO create a new db that can be readable
describe("Messages properties", function ()
	it("Add", function ()
		local maildir, db = u.create_db("padd")
    local message = u.insert_email(maildir, db)

    message:add_property('foo','bar')
    for k, v in message:get_properties('') do
      assert.equal(k, 'foo')
      assert.equal(v, 'bar')
    end
  end)
	it("Len", function ()
		local maildir, db = u.create_db("plen")
    local message = u.insert_email(maildir, db)
    message:add_property('bepa','moop')
    message:add_property('mepa','doop')

    assert.equal(message:count_properties('bepa'), 1)
  end)
	it("Remove all", function ()
		local maildir, db = u.create_db("premove")
    local message = u.insert_email(maildir, db)
    message:add_property('bepa','moop')
    message:add_property('mepa','doop')

    message:remove_all_properties()
  end)
	it("Get all", function ()
		local maildir, db = u.create_db("pall")
    local message = u.insert_email(maildir, db)
    message:add_property('foo','bar')

    for k, v in message:get_properties('') do
      assert.equal(k, 'foo')
      assert.equal(v, 'bar')
    end
  end)
end)
