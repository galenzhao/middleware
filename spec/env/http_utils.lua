local querystring  = require 'spec.env.querystring'
local url          = require 'socket.url' -- provided by luasocket

local http_utils = {}

---------------------------------

local function copy_recursive(t)
  if type(t) ~= 'table' then return t end
  local c = {}
  for k,v in pairs(t) do
    c[copy_recursive(k)] = copy_recursive(v)
  end
  setmetatable(c, getmetatable(t))
  return c
end

---------------------------------

function http_utils.complete_request(req)
  req = copy_recursive(req)

  local parseable_uri = req.url or req.uri_full or req.uri_relative or req.uri
  if parseable_uri then
    local info = url.parse(parseable_uri)
    req.scheme       = req.scheme       or info.scheme or 'http'
    req.host         = req.host         or info.host or 'localhost'
    req.uri          = (req.uri         or info.path):gsub('%?.*', '')
    req.query        = req.query        or info.query or ''
    req.args         = req.args         or querystring.parse(req.query)
    local has_query  = req.query == '' and '' or '?'
    req.uri_relative = req.uri_relative or (req.uri .. has_query .. req.query)
    req.uri_full     = req.uri_full     or (req.scheme .. '://' .. req.host .. req.uri_relative)
  else
    error("Invalid request: Must provide at least one of the following: url, uri, uri_full or uri_relative")
  end

  req.method  = req.method  or 'GET'
  req.headers = req.headers or {}
  req.body    = req.body    or ""

  return req
end

function http_utils.complete_response(res)
  res         = copy_recursive(res)

  res.status  = res.status  or 200
  res.body    = res.body    or 'ok (default body from spec.lua)'
  res.headers = res.headers or {}

  return res
end

return http_utils
