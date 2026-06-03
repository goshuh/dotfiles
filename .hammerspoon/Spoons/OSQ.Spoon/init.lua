local Canvas     = require 'hs.canvas'
local Drawing    = require 'hs.drawing'
local FnUtils    = require 'hs.fnutils'
local Http       = require 'hs.http'
local Json       = require 'hs.json'
local Screen     = require 'hs.screen'
local Spoons     = require 'hs.spoons'
local StyledText = require 'hs.styledtext'
local Timer      = require 'hs.timer'
local WebSocket  = require 'hs.websocket'


-- helpers
local function strip(s)
  return string.match(s, '^%s*(.-)%s*$')
end

local function head(s, n)
  return string.sub(s, 1, n)
end

local function tail(s, n)
  return string.sub(s, n)
end

local function head_as(s, p)
  return head(s, #p) == p
end

local function pad_left(t, n)
  local s = tostring(t)
  local l = string.len(s)

  if l >= n then
    return tail(s, l - n + 1)
  else
    return string.rep(' ', n - l) .. s
  end
end

local function pad_right(t, n)
  local s = tostring(t)
  local l = string.len(s)

  if l >= n then
    return head(s, n)
  else
    return s .. string.rep(' ', n - l)
  end
end


local _M = {
  name    = 'OSQ',
  version = '0.1',
  author  = 'gosh',
  license = 'None',

  gap     =  8,
  font    = 'Menlo',

  rise    =  {
    red   =  0xe0 / 0xff,
    green =  0x6c / 0xff,
    blue  =  0x75 / 0xff,
    alpha =  0.5
  },
  fall    =  {
    red   =  0x98 / 0xff,
    green =  0xc3 / 0xff,
    blue  =  0x79 / 0xff,
    alpha =  0.5
  },
  norm    =  {
    white =  1,
    alpha =  0.5
  },

  canvas  =  nil,
  timer   =  nil,
  socket  =  nil,

  to_cid  =  {},
  to_idx  =  {},

  key     =  '5432',
  token   =  '',
  quotes  =  '',
  stocks  =  {}
}

_M.__index = _M


function _M:ep_https(u)
  return 'https://localhost:' .. self.key .. '/v1/api' .. u
end

function _M:ep_wss()
  return 'wss://localhost:' .. self.key .. '/v1/api/ws?api=' .. self.token
end

function _M:start(fn)
  if self.quotes ~= '' or #self.stocks > 0 then
    return self
  end

  local f = io.open(os.getenv('HOME') .. '/' .. fn, 'r')

  if not f then
    return self
  end

  local segs = {}
  local syms = {}

  for line in f:lines() do
    local i = strip(line)

    if i == '' or head_as(i, '#') then
      -- skip
    elseif head_as(i, 'key: ') then
      self.key = strip(tail(i, 6))
    elseif head_as(i, 'sym: ') then
      table.insert(syms, strip(tail(i, 6)))
    else
      table.insert(segs, i)
    end
  end

  f:close()

  self.quotes = table.concat(segs, '\n')
  self.stocks = syms

  self:draw()
  self:init()

  return self
end

function _M:bindHotKeys(mapping)
  local spec = {
    reinit = FnUtils.partial(self.init, self)
  }

  Spoons.bindHotkeysToSpec(spec, mapping)

  return self
end

function _M:subs(s)
  local i = self.to_cid[s]

  if i then
    self.socket:send('smd+' .. i .. '+{"fields":["31","82","83"]}')
    return
  end

  local url = self:ep_https('/iserver/secdef/search?symbol=' .. s ..
                            '&name=true&secType=STK')

  Http.asyncGet(url, nil, function(c, res)
    if c ~= 200 then
      -- symbol may be invalid
      return
    end

    local ok, ret = pcall(Json.decode, res)

    if not ok or not ret then
      return
    end

    local i = tonumber(ret[1].conid)

    self.to_cid[s] = tostring(i)
    self.to_idx[i] = self.to_idx[s]

    self.socket:send('smd+' .. i .. '+{"fields":["31","82","83"]}')
  end)
end

function _M:subs_all()
  for _, s in ipairs(self.stocks) do
    self:subs(s)
  end
end

function _M:init()
  -- can fail. we just let the user reinit
  Http.asyncGet(self:ep_https('/tickle'), nil, function(c, res)
    if c ~= 200 then
      return
    end

    local ok, ret = pcall(Json.decode, res)

    if not ok or not ret then
      return
    end

    if not ret.iserver.authStatus.authenticated then
      return
    end

    self.token = ret.session or ''

    if self.token == '' then
      return
    end

    -- ready to start the ws
    self.socket = WebSocket.new(self:ep_wss(), function(c, msg)
      if c == 'open' then
        self:subs_all()

        -- re-subscribe every 10 min as the server expires every 15 mins
        self.timer = Timer.doEvery(600, function()
          self:subs_all()
        end)

      elseif c == 'received' then
        self:recv(msg)

      elseif c == 'closed'  or
             c == 'closing' then
        if self.timer then
          self.timer:stop()
          self.timer = nil
        end
      end
    end)
  end)
end

function _M:recv(msg)
  local ok, ret = pcall(Json.decode, msg)

  if not ok or not ret then
    return
  end

  if not head_as(ret.topic or '', 'smd+') then
    return
  end

  local s = self.canvas[self.to_idx[ret.conid]]

  local price   = tonumber(ret['31'])
  local change  = tonumber(ret['82'] or '0')
  local percent = tonumber(ret['83'] or '0')

  s.text =
    pad_left(string.format('%.2f', price),   8) ..
    pad_left(string.format('%.2f', change),  7) ..
    pad_left(string.format('%.2f', percent), 7) .. '%'

  if change > 0 then
    s.textColor = self.rise
  elseif change < 0 then
    s.textColor = self.fall
  else
    s.textColor = self.norm
  end
end

function _M:draw()
  local w = 0
  local h = 0

  local p = {}
  local t = {}

  for i, s in ipairs(self.stocks) do
    self.to_idx[s] = i

    local pt = ' ----.-- ---.-- ---.--%'
    local st =  pad_right(s, 4)

    local cx =  0
    local ch =  0

    local pf = Drawing.getTextDrawingSize(pt, {
      font = self.font,
      size = 12
    })

    table.insert(p, {
      type      = 'text',
      text      =  pt,
      textColor =  self.norm,
      textFont  =  self.font,
      textSize  =  12,
      frame = {
        x = cx,
        y = h,
        w = pf.w,
        h = pf.h
      }
    })

    cx = cx + pf.w
    ch = math.max(ch, pf.h)

    local sf = Drawing.getTextDrawingSize(st, {
      font = self.font,
      size = 12
    })

    table.insert(t, {
      type      = 'text',
      text      =  st,
      textColor =  self.norm,
      textFont  =  self.font,
      textSize  =  12,
      frame = {
        x = cx,
        y = h,
        w = sf.w,
        h = sf.h
      }
    })

    w = math.max(w,  sf.w  + cx)
    h = math.max(ch, sf.h) + h + self.gap
  end

  local qf = Drawing.getTextDrawingSize(self.quotes, {
    font      =  self.font,
    size      =  48,
    alignment = 'right',
    lineBreak = 'charWrap'
  })

  table.insert(t, {
    type          = 'text',
    text          =  self.quotes,
    textColor     =  self.norm,
    textFont      =  self.font,
    textSize      =  48,
    textAlignment = 'right',
    textLineBreak = 'charWrap',
    frame = {
      x = 0,
      y = h,
      w = qf.w,
      h = qf.h
    }
  })

  w = math.max(w, qf.w)
  h = h + qf.h

  -- create the final list
  local e = {}

  for _, a in ipairs(p) do
    table.insert(e, a)
  end

  for _, a in ipairs(t) do
    table.insert(e, a)
  end

  -- post process to make everything right-aligned
  for _, a in ipairs(e) do
    a.frame.x = w - a.frame.x - a.frame.w
  end

  local f = Screen.mainScreen():frame()
  local r = {
    x = f.x + f.w - w - self.gap,
    y = f.y + f.h - h - self.gap,
    w = w,
    h = h
  }

  self.canvas = Canvas.new(r)

  self.canvas:behavior({
    'canJoinAllSpaces',
    'stationary',
    'fullScreenAuxiliary'
  })

  self.canvas:clickActivating(false)
  self.canvas:bringToFront(false)
  self.canvas:replaceElements(e)
  self.canvas:show()
end


return _M
