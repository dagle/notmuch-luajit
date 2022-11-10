local nm = require("notmuch.db")
local u = require("test/test/util")

local mid = "6391af02ba7ec4a76c5c5f462d8013fc1f52f999.1289789604.git.joe@perches.com"

describe("Tags", function ()
	it("Read tags", function ()
		local db = nm.db_open(nil, 0, nil, nil)

    local message = db:find_message(mid)
    local tags = u.collect(message:get_tags())

    assert.equal(tags[1], "inbox")
    assert.equal(tags[2], "unread")
  end)
	it("Add tags", function ()
		local maildir, db = u.create_db("tgadd")
    local message = u.insert_email(maildir, db)
    message:add_tag("test_tag")

    local tags = u.collect(message:get_tags())

    assert.equal(tags[1], "test_tag")
  end)
	it("Remove tag", function ()
		local maildir, db = u.create_db("tremove")
    local message = u.insert_email(maildir, db)
    message:add_tag("test_tag")

    local tags = u.collect(message:get_tags())

    assert.equal(tags[1], "test_tag")

    message:remove_tag("test_tag")
    tags = u.collect(message:get_tags())

    assert.equal(tags[1], nil)
  end)
	it("Remove all", function ()
		local maildir, db = u.create_db("tremoveall")
    local message = u.insert_email(maildir, db)
    message:add_tag("test_tag")

    local tags = u.collect(message:get_tags())

    assert.equal(tags[1], "test_tag")

    message:remove_all_tags()
    local tags = u.collect(message:get_tags())
    assert.equal(tags[1], nil)
  end)
end)
