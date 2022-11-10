local nm = require("notmuch.db")
local u = require("test/test/util")

describe("Configuration", function ()
	it("Read config value", function ()
		local db = nm.db_open(nil, 0, nil, nil)
    assert.equal(db.conf["apa"], "")
  end)
	it("Set and read", function ()
		local _, db = u.create_db("cset")
    db.conf.spam = 'ham'
    db.conf.eggs = 'bacon'

    assert.equal(db.conf.spam, 'ham')
    assert.equal(db.conf.eggs, 'bacon')
  end)
	it("Delete value", function ()
		local _, db = u.create_db("cset")
    db.conf.spam = 'ham'
    assert.equal(db.conf.spam, 'ham')

    db.conf.spam = ''
    assert.equal(db.conf.spam, '')
  end)
	it("Iterate over values", function ()
		local db = nm.db_open(nil, 0, nil, nil)
    for value in db:conf_iter() do
    end
  end)
	it("Count values", function ()
		local _, db = u.create_db("cset")
    local len = db:conf_len()
    db.conf.spam = 'ham'
    db.conf.eggs = 'bacon'
    local new_len = db:conf_len()
    assert.equal(len+2, new_len)
  end)
end)
