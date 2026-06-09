local Canvas     = require 'hs.canvas'
local Drawing    = require 'hs.drawing'
local FnUtils    = require 'hs.fnutils'
local Host       = require 'hs.host'
local Json       = require 'hs.json'
local Screen     = require 'hs.screen'
local Spoons     = require 'hs.spoons'
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

  file    = '',
  remote  = 'wss://data.tradingview.com/' ..
                  'socket.io/websocket?from=chart&type=chart',

  canvas  =  nil,
  socket  =  nil,
  session =  '',

  to_idx  =  {},

  quotes  =  '',
  stocks  =  {}
}

_M.__index = _M


function _M:start(fn)
  self:stop()

  if self.canvas then
    self.canvas:delete()
    self.canvas = nil
  end

  self.quotes = ''
  self.stocks = {}

  self.file   = fn and fn or self.file

  local f = io.open(os.getenv('HOME') .. '/' .. self.file, 'r')

  if not f then
    return self
  end

  local segs = {}
  local syms = {}

  for line in f:lines() do
    local i = strip(line)

    if i == '' or head_as(i, '#') then
      -- skip
    elseif head_as(i, 'sym: ') then
      table.insert(syms, strip(tail(i, 6)))
    else
      table.insert(segs, i)
    end
  end

  f:close()

  self.quotes = table.concat(segs, '\n')

  for _, s in ipairs(syms) do
    table.insert(self.stocks, {
      symbol  = s,
      price   = 0,
      change  = 0,
      percent = 0
    })
  end

  self:draw()
  self:sess()

  self.socket = WebSocket.new(self.remote, function(c, msg)
    if c == 'open' then
      self:open()

    elseif c == 'received' then
      self:recv(msg)

    elseif c == 'closed'  or
           c == 'closing' then
      if self.socket then
        self.socket:close()
        self.socket = nil
      end
    end
  end)

  return self
end

function _M:stop()
  if not self.socket then
    return
  end

  self:send({
    m = 'quote_delete_session',
    p = {
      self.session
    }
  })
  self.socket:close()

  self.socket = nil
end

function _M:bindHotKeys(mapping)
  local spec = {
    start = FnUtils.partial(self.start, self),
    stop  = FnUtils.partial(self.stop,  self)
  }

  Spoons.bindHotkeysToSpec(spec, mapping)

  return self
end

function _M:sess()
  math.randomseed(os.time() ~ Host.idleTime())

  local c = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  local r = {}

  for i = 1, 12 do
    local j = math.random(1, #c)

    r[i] = string.sub(c, j, j)
  end

  self.session = 'qs_' .. table.concat(r)
end

function _M:open()
  self:send({
    m = 'set_auth_token',
    p = {
      'unauthorized_user_token'
    }
  })

  self:send({
    m = 'quote_create_session',
    p = {
      self.session
    }
  })

  self:send({
    m = 'quote_set_fields',
    p = {
      self.session,
     'lp',
     'ch',
     'chp'
    }
  })

  for _, q in ipairs(self.stocks) do
    self:send({
      m = 'quote_add_symbols',
      p = {
        self.session,
        q.symbol
      }
    })
  end
end

function _M:send(msg)
  if not self.socket then
    return
  end

  local m = type(msg) == 'string' and msg or Json.encode(msg)

  self.socket:send('~m~' .. tostring(#m) .. '~m~' .. m)
end

function _M:recv(msg)
  if not self.socket then
    return
  end

  local r = FnUtils.split(msg, '~m~%d+~m~')

  for _, s in ipairs(r) do
    if head_as(s, '~h~') then
      self:send(s)

    elseif #s > 0 then
      local ok, ret = pcall(Json.decode, s)

      if ok and ret and ret.m == 'qsd' then
        local p = ret.p[2]

        if p.s == 'ok' then
          local i = self.to_idx[p.n]
          local s = self.stocks[i]
          local t = self.canvas[i]

          s.price   = p.v.lp  and p.v.lp  or s.price
          s.change  = p.v.ch  and p.v.ch  or s.change
          s.percent = p.v.chp and p.v.chp or s.percent

          t.text =
            pad_left(string.format('%.2f', s.price),   8) ..
            pad_left(string.format('%.2f', s.change),  7) ..
            pad_left(string.format('%.2f', s.percent), 7) .. '%'

          if s.change > 0 then
            t.textColor = self.rise
          elseif s.change < 0 then
            t.textColor = self.fall
          else
            t.textColor = self.norm
          end
        end
      end
    end
  end
end

function _M:draw()
  local w = 0
  local h = 0

  local p = {}
  local t = {}

  for i, s in ipairs(self.stocks) do
    local ss =  FnUtils.split(s.symbol, ':')

    self.to_idx[s.symbol] = i

    local pt = ' ----.-- ---.-- ---.--%'
    local st =  pad_right(ss[#ss], 4)

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
