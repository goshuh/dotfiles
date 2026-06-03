local Canvas     = require 'hs.canvas'
local Drawing    = require 'hs.drawing'
local Http       = require 'hs.http'
local Json       = require 'hs.json'
local Screen     = require 'hs.screen'
local StyledText = require 'hs.styledtext'
local Timer      = require 'hs.timer'


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
  period  =  3,
  font    = 'Menlo',
  iter    =  1,

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

  key     =  '',
  quotes  =  '',
  stocks  =  {}
}

_M.__index = _M


function _M:start(fn)
  if self.key ~= '' or self.quotes ~= '' or #self.stocks > 0 then
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

  if self.key ~= '' and #self.stocks > 0 then
    self.timer = Timer.doEvery(self.period, function()
      self:fetch()
    end)
  end

  return self
end

function _M:fetch()
  local s = self.stocks[self.iter]
  local t = self.canvas[self.iter]

  local url = 'https://finnhub.io/api/v1/quote?symbol=' .. s ..
              '&token=' .. self.key

  Http.asyncGet(url, nil, function(_, res, _)
    local ok, ret = pcall(Json.decode, res)

    if not ok or not ret then
      return
    end

    t.text = pad_left(string.format('%.2f', ret.c),  8) ..
             pad_left(string.format('%.2f', ret.d),  7) ..
             pad_left(string.format('%.2f', ret.dp), 7) .. '%'

    if ret.d > 0 then
      t.textColor = self.rise
    elseif ret.d < 0 then
      t.textColor = self.fall
    else
      t.textColor = self.norm
    end
  end)

  self.iter = self.iter == #self.stocks and 1 or (self.iter + 1)
end

function _M:draw()
  local w = 0
  local h = 0

  local p = {}
  local t = {}

  for _, s in ipairs(self.stocks) do
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
