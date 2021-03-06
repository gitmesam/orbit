local luasql = require "luasql.sqlite3"
local orm = require "orbit.model"

local args = { ... }

local env = luasql()
local conn = env:connect(args[1] .. ".db")

local mapper = orm.new("toycms_", conn, "sqlite3")

local tables = { "post", "comment", "user", "section" }

print("local db = '" .. args[1] .. "'")

print [[

local luasql = require "luasql.mysql"
local orm = require "orbit.model"

local env = luasql()
local conn = env:connect(db, "root", "password")

local mapper = orm.new("toycms_", conn, "mysql")

]]

local function serialize_prim(v)
  local type = type(v)
  if type == "string" then
    return string.format("%q", v)
  else
    return tostring(v)
  end
end

local function serialize(t)
  local fields = {}
  for k, v in pairs(t) do
    table.insert(fields, " [" .. string.format("%q", k) .. "] = " ..
	       serialize_prim(v))
  end
  return "{\n" .. table.concat(fields, ",\n") .. "}"
end

for _, tn in ipairs(tables) do
  print("\n-- Table " .. tn .. "\n")
  local t = mapper:new(tn)
  print("local t = mapper:new('" .. tn .. "')")
  local recs = t:find_all()
  for i, rec in ipairs(recs) do
    print("\n-- Record " .. i .. "\n")
    print("local rec = " .. serialize(rec))
    print("rec = t:new(rec)")
    print("rec:save(true)")
  end
end
