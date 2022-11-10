local nm = require("notmuch.db")

local M = {}

function M.collect(it)
  local box = {}

  for v in it do
    table.insert(box, v)
  end
  return box
end

local function create_email(headers, body)
  local box = {}

  for k, v in pairs(headers) do
    table.insert(box, string.format("%s: %s", k, v))
  end

  table.insert(box, "")
  table.insert(box, body)
  table.insert(box, "")
  return table.concat(box, "\n")
end

local headers = {
  From = "Test <test@test.org>",
  To = "Cest <cest@test.org>",
  Subject = "This is a testmail",
  Date = "Sun, 14 Nov 2010 19:04:30 -0800",
}

local body = "Hello"


local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
math.randomseed(os.time())

local function randomstring_helper(length)
  if length > 0 then
    local pos = math.random(1, #charset)
    local char = string.sub(charset, pos, pos)
    return randomstring_helper(length - 1) .. char
  else
    return ""
  end
end

local function randomstring(length)
  return randomstring_helper(length)
end

local function genfilename()
  local date = os.time(os.date("!*t"))
  local id = vim.fn.getpid()
  return string.format("%d.%d:2,", date, id)
end

--- create a new db 
function M.create_db(name)
  local maildir = vim.fn.getcwd() .. "/test/testdir/".. name .. randomstring(10) .. "/"
  vim.fn.mkdir(maildir)

  vim.fn.mkdir(maildir .. "cur")
  vim.fn.mkdir(maildir .. "new")
  vim.fn.mkdir(maildir .. "tmp")

  local conf = maildir .. 'notmuch-config'
  local notmuch = assert(io.open(conf, "w+"), "Couldn't open file")
  notmuch:write(
    string.format(
      [[
        [database]
        path=%s
        [user]
        name=Test McTest
        primary_email=test@test.org
        [new]
        tags=unread;inbox;
        ignore=
        [search]
        exclude_tags=deleted;spam;
        [maildir]
        synchronize_flags=true
      ]], maildir)
  )
  local db = nm.db_create(maildir, conf, nil)
  return maildir, db
end

function M.insert_email(maildir, db)
  local mid = "<" .. randomstring(12) .. "@test.org>"
  headers["Message-ID"] = mid

  local str = create_email(headers, body)

  local filename = maildir .. genfilename()

  local file = assert(io.open(filename, "w"), "Couldn't open file")
  file:write(str)
  file:close()

  local message = db:index_file(filename)

  return message
end

return M
