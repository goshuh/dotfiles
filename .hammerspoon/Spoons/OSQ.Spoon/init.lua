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
  period  =  60,
  font    = 'Menlo',
  state   =  0,

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

  overlay =  nil,
  timer   =  nil,

  key     =  '',
  text    =  '',
  stocks  =  {}
}

_M.__index = _M


function _M:start(fn)
  if self.key ~= '' or self.text ~= '' or #self.stocks > 0 then
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

  self.text = table.concat(segs, '\n')

  for _, s in ipairs(syms) do
    table.insert(self.stocks, {
      symbol  = s,
      price   = 0,
      change  = 0,
      percent = 0,
      ready   = false
    })
  end

  self:update()

  if self.key ~= '' and #self.stocks > 0 then
    self:fetch()
    self.timer = Timer.doEvery(self.period, function()
      self:fetch()
    end)
  end

  return self
end

function _M:fetch()
  for i, s in ipairs(self.stocks) do
    local url = 'https://finnhub.io/api/v1/quote?symbol=' .. s.symbol ..
                '&token=' .. self.key

    Http.asyncGet(url, nil, function(_, res, _)
      local ok, ret = pcall(Json.decode, res)

      if not ok or not ret then
        return
      end

      s.price   = ret.c  or 0
      s.change  = ret.d  or 0
      s.percent = ret.dp or 0
      s.ready   = true

      self:update()
    end)
  end
end

function _M:update()
  if self.state > 0 then
    return
  end

  self.state = 1

  local w = 0
  local h = 0

  local elements = {}

  for _, s in ipairs(self.stocks) do
    local cx = 0
    local ch = 0

    local pr = '----.-- --.-- --.--%'
    local pc = {
      white = 1,
      alpha = 0.5
    }

    if s.ready then
      pr = pad_left(string.format('%.2f', math.abs(s.price  )), 8) ..
           pad_left(string.format('%.2f', math.abs(s.change )), 6) ..
           pad_left(string.format('%.2f', math.abs(s.percent)), 6) .. '%'

      if s.change > 0 then
        pc = self.rise
      elseif s.change < 0 then
        pc = self.fall
      end
    end

    local pt = StyledText.new(pr, {
      font  = {
        name = self.font,
        size = 12
      },
      color = pc
    })
    -- pretty bad it asks for a different style
    local pf = Drawing.getTextDrawingSize(pt, {
      font = self.font,
      size = 12
    })

    table.insert(elements, {
      type  = 'text',
      text  =  pt,
      frame = {
        x = cx,
        y = h,
        w = pf.w,
        h = pf.h
      }
    })

    cx = cx + pf.w
    ch = math.max(ch, pf.h)

    local st = StyledText.new(pad_right(s.symbol, 4), {
      font  = {
        name  = self.font,
        size  = 12
      },
      color = {
        white = 1,
        alpha = 0.5
      }
    })
    local sf = Drawing.getTextDrawingSize(st, {
      font = self.font,
      size = 12
    })

    table.insert(elements, {
      type  = 'text',
      text  =  st,
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

  local qt = StyledText.new(self.text, {
    font  = {
      name  = self.font,
      size  = 48
    },
    color = {
      white = 1,
      alpha = 0.5
    },
    paragraphStyle = {
      alignment = 'right',
      linebreak = 'charWrap'
    }
  })
  local qf = Drawing.getTextDrawingSize(qt, {
    font      =  self.font,
    size      =  48,
    alignment = 'right',
    lineBreak = 'charWrap'
  })

  table.insert(elements, {
    type  = 'text',
    text  =  qt,
    frame = {
      x = 0,
      y = h,
      w = qf.w,
      h = qf.h
    }
  })

  w = math.max(w, qf.w)
  h = h + qf.h

  -- post process to make everything right-aligned
  for _, e in ipairs(elements) do
    e.frame.x = w - e.frame.x - e.frame.w
  end

  local f = Screen.mainScreen():frame()
  local r = {
    x = f.x + f.w - w - self.gap,
    y = f.y + f.h - h - self.gap,
    w = w,
    h = h
  }

  if not self.overlay then
    self.overlay = Canvas.new(r)

    self.overlay:behavior({
      'canJoinAllSpaces',
      'stationary',
      'fullScreenAuxiliary'
    })

    self.overlay:clickActivating(false)
    self.overlay:bringToFront(false)
    self.overlay:show()
  else
    self.overlay:frame(r)
  end

  self.overlay:replaceElements(elements)

  self.state = 0
end


return _M
