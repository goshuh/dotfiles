local AXUIElem  = require 'hs.axuielement'
local EventTap  = require 'hs.eventtap'
local FnUtils   = require 'hs.fnutils'
local Geometry  = require 'hs.geometry'
local Inspect   = require 'hs.inspect'
local Mouse     = require 'hs.mouse'
local Screen    = require 'hs.screen'
local Spaces    = require 'hs.spaces'
local Spoons    = require 'hs.spoons'
local Timer     = require 'hs.timer'
local Window    = require 'hs.window'
local Watcher   = require 'hs.uielement.watcher'


-- bad
Window.animationDuration = 0


local _M = {
  gap      =  8,
  ratio    =  0.64,
  state    =  0,

  screen   =  nil,
  filter   =  nil,
  switcher =  nil,

  spaces   =  {},
  windows  =  {},

  name     = 'XWM',
  version  = '0.1',
  author   = 'gosh',
  license  = 'None'
}

_M.__index = _M


function _M:reinit()
  -- disable re-entrance from the screen watcher
  if self.state == 2 then
    return self
  end

  self.spaces  = {}
  self.windows = {}

  for _, r in ipairs(Screen.allScreens()) do
    local f = r:frame()

    f.x = f.x + self.gap
    f.y = f.y + self.gap
    f.w = f.w - self.gap * 2
    f.h = f.h - self.gap * 2

    for _, s in ipairs(Spaces.spacesForScreen(r)) do
      self.spaces[s] = {
        frame   = f,
        windows = {}
      }
    end
  end

  for _, w in ipairs(self.filter:getWindows()) do
    self:insert(w)
  end

  for s, _ in pairs(self.spaces) do
    self:retile(s)
  end

  self.state = 3

  return self
end

function _M:start()
  Window.switcher.ui.highlightColor        = {0.4, 0.4, 0.4}
  Window.switcher.ui.backgroundColor       = {0.9, 0.9, 0.9}
  Window.switcher.ui.showTitles            =  false
  Window.switcher.ui.showSelectedTitle     =  false
  Window.switcher.ui.showThumbnails        =  false
  Window.switcher.ui.showSelectedThumbnail =  false

  if not self.screen then
    self.screen = Screen.watcher.new(function()
      self.state = 2
      self:reinit()
    end)

    self.screen:start()
  end

  if not self.filter then
    self.filter = Window.filter.new():setOverrideFilter({
      visible     =  true,
      hasTitlebar =  true,
      fullscreen  =  false,
      allowRoles  = 'AXStandardWindow'
    })

    self.filter:subscribe({
      Window.filter.windowVisible,
      Window.filter.windowNotVisible,
      Window.filter.windowFullscreened,
      Window.filter.windowUnfullscreened,
      Window.filter.windowDestroyed
    }, function (w, _, e)
      self:handler(w, e)
    end)
  end

  if not self.switcher then
    self.switcher = Window.switcher.new(
      Window.filter.new():setCurrentSpace(true):setDefaultFilter({}))
  end

  self.state = 1

  return self:reinit()
end

function _M:stop()
  if self.state > 0 then
    self.filter:unsubscribeAll()
    self.screen:stop()
  end

  self.state    = 0

  self.screen   = nil
  self.filter   = nil
  self.switcher = nil

  self.spaces   = {}
  self.windows  = {}

  return self
end

function _M:bindHotkeys(mapping)
  local spec = {
    retile      = FnUtils.partial(self.retile, self),

    swap_prev   = FnUtils.partial(self.swap,   self, -1),
    swap_next   = FnUtils.partial(self.swap,   self,  1),
    swap_master = FnUtils.partial(self.swap,   self,  0),

    skid        = FnUtils.partial(self.skid,   self),

    prev        = FnUtils.partial(self.prev,   self),
    next        = FnUtils.partial(self.next,   self)
  }

  for i = 1, 10 do
    spec['jump_' .. tostring(i)] = FnUtils.partial(self.jump, self, i)
  end

  Spoons.bindHotkeysToSpec(spec, mapping)

  return self
end

function _M:handler(window, event)
  -- Events.windowEventHandler
  if not window['id'] then
    return
  end

  local s = nil

  if event == 'windowVisible' or
     event == 'windowUnfullscreened' then
    s = self:insert(window)

    if not s then
      Timer.doAfter(0.1, function()
        self:handler(window, event)
      end)
    else
      local n = Spaces.windowSpaces(window)[1]

      if n and n ~= s then
        self:delete(window)
        self.insert(window)
      end
    end

  elseif event == 'windowNotVisible' then
    s = self:delete(window)

  elseif event == 'windowFullscreened' then
    s = self:delete(window)

  elseif event == 'AXWindowMoved' or
         event == 'AXWindowResized' then
    s = Spaces.windowSpaces(window)[1]

    local d = self.windows[window:id()]

    if s and d.space ~= s then
      self:delete(window)
      self:insert(window)
    end

  elseif event == 'windowDestroyed' then
    self:delay(window)
  end

  if s then
    self:retile(s)
  end
end

function _M:layout(windows, i, frame)
  local n = #windows

  if n == 1 then
    return frame
  end

  local w = frame.w * self.ratio - self.gap / 2

  if i == 1 then
    return Geometry.rect(
      frame.x,
      frame.y,
      w,
      frame.h
    )
  else
    local j =  i - 2
    local h = (frame.h + self.gap) / (n - 1)

    return Geometry.rect(
      frame.x + w + self.gap,
      frame.y + j * h,
      frame.w - w - self.gap,
      h - self.gap
    )
  end
end

function _M:retile(space)
  if not space then
    space = Spaces.focusedSpace()
  end

  local p = self.spaces[space]

  if not p or Spaces.spaceType(space) ~= 'user' then
    return
  end

  -- best effort for multi-tab windows (where each tab can be reported as a
  -- window): allow each app to be appeared only once
  local pids = {}
  local wins = {}

  for _, w in ipairs(p.windows) do
    local a = w:application()

    if a then
      local d = a:pid()

      if not pids[d] then
        pids[d] = true

        table.insert(wins, w)
      end
    end
  end

  for i, w in ipairs(wins) do
    local f = self:layout(wins, i, p.frame)

    if w:frame() ~= f then
      -- https://github.com/Hammerspoon/hammerspoon/issues/3224
      local e = AXUIElem.applicationElement(w:application())
      local x = e.AXEnhancedUserInterface
      local d = self.windows[w:id()]

      d.watcher:stop()

      if x then
        e.AXEnhancedUserInterface = false
      end

      w:setFrame(f, 0)

      if x then
        e.AXEnhancedUserInterface = true
      end

      d.watcher:start({
        Watcher.windowMoved,
        Watcher.windowResized
      })
    end
  end
end

local whitelist = {
  -- no suiside after closing the console
  ['org.hammerspoon.Hammerspoon'] = true,
  -- unstable after killed and restarted multiple times
  ['com.apple.finder'           ] = true,
  -- long-running stuff
  ['com.tencent.xinWeChat'      ] = true,
  ['com.tinyspeck.slackmacgap'  ] = true,
  ['com.microsoft.Outlook'      ] = true,
  ['com.microsoft.OneDrive'     ] = true,
  ['com.cisco.anyconnect.gui'   ] = true,
  ['ru.keepcode.Telegram'       ] = true
}

function _M:insert(window)
  -- Windows.addWindow
  local s = Spaces.windowSpaces(window)[1]
  local c = window:tabCount()

  if not s then
    return
  end

  if c > 0 then
    local a = window:application()

    if a then
      for _, w in ipairs(a:allWindows()) do
        if w ~= window then
          self:insert(w)
        end
      end
    end
  end

  local d = self.windows[window:id()]

  if d or not window:isStandard() then
    return d.space
  end

  -- State.uiWatcherCreate
  local i = window:id()
  local w = window:newWatcher(function(w, e, _)
    self:handler(w, e)
  end)

  w:start({
    Watcher.windowMoved,
    Watcher.windowResized
  })

  self.windows[i] = {
    space   = s,
    watcher = w,
  }

  -- master by default
  table.insert(self.spaces[s].windows, 1, window)

  return s
end

function _M:delete(window)
  -- Windows.removeWindow
  local d = self.windows[window:id()]

  if not d then
    return
  end

  self.windows[window:id()] = nil

  -- State.uiWatcherStop
  -- State.uiWatcherDelete
  d.watcher:stop()
  d.watcher = nil

  local i = nil

  for j, w in ipairs(self.spaces[d.space].windows) do
    if w == window then
      i = j
      break
    end
  end

  if i then
    table.remove(self.spaces[d.space].windows, i)
  end

  return d.space
end

function _M:delay(window)
  local a = window:application()

  if not a then
    return
  end

  local b = a:bundleID()

  if not b or whitelist[b] then
    return
  end

  Timer.doAfter(3, function()
    if a and a:isRunning() then
      -- not only in the current space
      for _, w in ipairs(self.filter:getWindows()) do
        if w:application():bundleID() == b then
          return
        end
      end

      -- no windows, kill
      a:kill()
    end
  end)
end

function _M:swap(forward)
  local w = Window.focusedWindow()
  local s = Spaces.focusedSpace()

  if not w or not s then
    return
  end

  local p = self.spaces[s]

  if not p then
    return
  end

  -- ordered list
  local i = nil

  for j, v in ipairs(p.windows) do
    if v == w then
      i = j
      break
    end
  end

  if i then
    local j = forward == 0 and 1 or forward + i

    if j >= 1 and j <= #p.windows then
      p.windows[i], p.windows[j] =
      p.windows[j], p.windows[i]
    end
  end

  self:retile(s)
end

function _M:move(window, curr, next, str)
  if not window:isStandard() or window:isFullScreen() then
    return
  end

  if not next or curr == next then
    return
  end

  self:delete(window)
  self:retile(curr)

  local o = Mouse.getRelativePosition()
  local p = Geometry.rect(window:zoomButtonRect()):move({ -1, -1 }).topleft

  EventTap.event.newMouseEvent(
    EventTap.event.types.leftMouseDown, p):post()

  -- only for me
  EventTap.keyStroke({ 'ctrl' }, str)

  Timer.waitUntil(function()
    return Spaces.windowSpaces(window)[1] == next
  end, function()
    EventTap.event.newMouseEvent(
      EventTap.event.types.leftMouseUp, p):post()

    Mouse.setRelativePosition(o)

    self:insert(window)
    self:retile(next)
  end, 0.05)
end

function _M:jump(index)
  local w = Window.focusedWindow()
  local s = Spaces.focusedSpace()

  if not w or not s then
    return
  end

  local l = Spaces.spacesForScreen(w:screen())

  if not l then
    return
  end

  self:move(w, s, l[index], tostring(index))
end

function _M:skid()
  local w = Window.focusedWindow()
  local s = Spaces.focusedSpace()

  if not w or not s then
    return
  end

  local c = w:screen()
  local n = c:next()
  local l = Spaces.spacesForScreen(n)

  if c == n or not l then
    return
  end

  local i = nil

  for j, t in ipairs(Spaces.spacesForScreen(c)) do
    if t == s then
      i = j
      break
    end
  end

  if not i then
    return
  end

  self:move(w, s, l[i], tostring(i))
end

function _M:prev()
  self.switcher:previous()
end

function _M:next()
  self.switcher:next()
end


return _M
