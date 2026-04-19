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


-- helpers
local function get_index(t, func)
  if not t then
    return nil, nil
  end

  for i, v in ipairs(t) do
    if func(v) then
      return i, v
    end
  end

  return nil, nil
end


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
  entries  =  {},

  name     = 'XWM',
  version  = '0.1',
  author   = 'gosh',
  license  = 'None',

  persist  =  {},
  tabbed   =  {}
}

_M.__index = _M


function _M:clear()
  for _, d in pairs(self.windows) do
    if d.watcher then
      d.watcher:stop()
      d.watcher = nil
    end
  end

  self.spaces  = {}
  self.windows = {}
  self.entries = {}

  return self
end

function _M:reinit()
  if self.state > 0 then
    return self
  end

  self.state = 1
  self:clear()

  for _, r in ipairs(Screen.allScreens()) do
    local f = r:frame()

    f.x = math.floor(f.x + self.gap)
    f.y = math.floor(f.y + self.gap)
    f.w = math.floor(f.w - self.gap * 2)
    f.h = math.floor(f.h - self.gap * 2)

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

  self.state = 0

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
      Window.filter.windowFocused,
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

  return self:reinit()
end

function _M:stop()
  self.screen   = nil
  self.filter   = nil
  self.switcher = nil

  return self:clear()
end

function _M:bindHotkeys(mapping)
  local spec = {
    reinit      = FnUtils.partial(self.reinit, self),
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

  if event == 'windowFocused' or
     event == 'windowVisible' or
     event == 'windowUnfullscreened' then
    s = self:insert(window)

    if not s then
      Timer.doAfter(0.1, function()
        self:handler(window, event)
      end)
    elseif s >= 0 then
      local n = Spaces.windowSpaces(window)[1]

      if n and n ~= s then
        self:move(window, s, n)
        return
      end
    end

  elseif event == 'windowNotVisible' then
    s = self:delete(window)
    window = nil

  elseif event == 'windowFullscreened' then
    s = self:delete(window)
    window = nil

  elseif event == 'AXWindowMoved' or
         event == 'AXWindowResized' then
    s = Spaces.windowSpaces(window)[1]

    local i = window:id()
    local d = self.windows[i]

    if s and d.space ~= s then
      self:move(window, d.space, s)
      return
    end

  elseif event == 'windowDestroyed' then
    self:delay(window)
  end

  if s and s >= 0 then
    self:retile(s, window)
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
      math.floor(frame.x),
      math.floor(frame.y),
      math.floor(w),
      math.floor(frame.h)
    )
  else
    local j =  i - 2
    local h = (frame.h + self.gap) / (n - 1)

    return Geometry.rect(
      math.floor(frame.x + w + self.gap),
      math.floor(frame.y + j * h),
      math.floor(frame.w - w - self.gap),
      math.floor(h - self.gap)
    )
  end
end

function _M:retile(space, ext)
  if not space then
    space = Spaces.focusedSpace()
  end

  local p = self.spaces[space]
  local n = 0

  if not p or Spaces.spaceType(space) ~= 'user' then
    return
  end

  -- ext initiates the retile
  local i = ext and ext:id() or nil
  local d = self.windows[i]

  -- the special handling only happens on tabs
  if i and not d.entry then
    i = nil
  end

  repeat
    -- some window might disappear during retile
    local wins = {}

    for _, w in ipairs(p.windows) do
      local j = w:id()

      if self.windows[j] and w:application() then
        if i and d.entry == j then
          -- use the tab in replacement of the window temporarily
          table.insert(wins, ext)
        else
          table.insert(wins, w)
        end
      end
    end

    n = #wins

    for j, w in ipairs(wins) do
      local f = self:layout(wins, j, p.frame)
      local a = w:application()

      if not a then
        break
      end

      n = n - 1

      if w:frame() ~= f then
        -- https://github.com/Hammerspoon/hammerspoon/issues/3224
        local d = self.windows[w:id()]

        d.watcher:stop()
        w:setFrame(f, 0)

        d.watcher:start({
          Watcher.windowMoved,
          Watcher.windowResized
        })
      end
    end
  until n == 0
end

function _M:insert(window, ext)
  -- Windows.addWindow
  local s = ext and ext or Spaces.windowSpaces(window)[1]

  if not s then
    -- retry
    return nil
  end

  local i = window:id()
  local d = self.windows[i]

  if d then
    -- already registered
    d.space = s

    return d.entry and -1 or d.space
  end

  if not self.spaces[s] or
     not window:isStandard() or
     not window:isMaximizable() then
    return -1
  end

  -- tab management, can be bypassed
  local c = ext and 0 or window:tabCount()

  if c > 1 then
    local a = window:application()
    local b = a:bundleID()

    if b and self.tabbed[b] then
      -- track the association
      local f = window:frame()

      local _, w = get_index(self.spaces[s].windows, function(v)
        return v:frame() == f
      end)

      -- we are pretty sure about the behavior
      assert(w)

      -- link the tab
      local j = w:id()
      local e = self.entries[j]

      if not e then
        e = {
          num  = 0,
          tabs = {}
        }

        self.entries[j] = e
      end

      e.num     = e.num + 1
      e.tabs[i] = true

      local t = window:newWatcher(function(w, e, _)
        self:handler(w, e)
      end)

      t:start({
        Watcher.windowMoved,
        Watcher.windowResized
      })

      self.windows[i] = {
        space   = s,
        entry   = j,
        window  = window,
        watcher = t
      }

      -- then let it be
      return -1
    end
  end

  -- State.uiWatcherCreate
  local t = window:newWatcher(function(w, e, _)
    self:handler(w, e)
  end)

  t:start({
    Watcher.windowMoved,
    Watcher.windowResized
  })

  -- record the creation order of tabs
  self.windows[i] = {
    space   = s,
    entry   = nil,
    window  = window,
    watcher = t
  }

  -- master by default
  table.insert(self.spaces[s].windows, 1, window)

  return s
end

function _M:delete(window)
  local i = window:id()
  local d = self.windows[i]

  if not d then
    return nil
  end

  -- State.uiWatcherStop
  -- State.uiWatcherDelete
  d.watcher:stop()
  d.watcher = nil

  if d.entry then
    -- a tab, just deregister
    local e = self.entries[d.entry]

    e.num     = e.num - 1
    e.tabs[i] = nil

    if e.num == 0 then
      self.entries[d.entry] = nil
    end

    self.windows[i] = nil

    -- even without :retile
    return nil
  end

  local s = d.space
  local p = self.spaces [s]
  local e = self.entries[i]

  self.windows[i] = nil

  if not e then
    local k, _ = get_index(p.windows, function(v)
      return v == window
    end)

    table.remove(p.windows, k)
    return s
  end

  -- the window contains at least one following tab
  -- find the first child
  local f = nil
  local n = 0

  for k, _ in pairs(e.tabs) do
    if n == 0 then
      f = k
      n = 1
    else
      local v = self.windows[k]

      v.space = s
      v.entry = f
    end
  end

  -- update the new child
  local g = self.windows[f]

  g.space = s
  g.entry = nil

  -- update the registration
  e.num     = e.num - 1
  e.tabs[f] = nil

  self.entries[i] = nil
  self.entries[f] = e.num > 0 and e or nil

  -- replace the old position
  local k, _ = get_index(p.windows, function(v)
    return v == window
  end)

  p.windows[k] = w
  return s
end

function _M:delay(window)
  local a = window:application()

  if not a then
    return
  end

  local b = a:bundleID()

  if not b or self.persist[b] then
    return
  end

  Timer.doAfter(3, function()
    if not a or not a:isRunning() then
      return
    end

    -- not only in the current space
    local i, _ = get_index(self.filter:getWindows(), function(v)
      return v:application():bundleID() == b
    end)

    if not i then
      a:kill()
    end
  end)
end

function _M:swap(fwd)
  local w = Window.focusedWindow()
  local s = Spaces.focusedSpace()

  if not w or not s then
    return
  end

  local d = self.windows[w:id()]

  if not d then
    return
  end

  if d.entry then
    w = self.windows[d.entry].window
  end

  local p = self.spaces[s]

  if not p then
    return
  end

  local i, _ = get_index(p.windows, function(v)
    return v == w
  end)

  if i then
    local j = fwd == 0 and 1 or fwd + i

    if j >= 1 and j <= #p.windows then
      p.windows[i], p.windows[j] =
      p.windows[j], p.windows[i]
    end
  end

  self:retile(s, w)
end

function _M:move(window, cur, nxt, str)
  if not window:isStandard() or window:isFullScreen() then
    return
  end

  if not nxt or cur == nxt then
    return
  end

  -- we might be moving a tab. move the underlying window instead
  local d = self.windows[window:id()]
  local w = d.entry and self.windows[d.entry].window or window

  -- not actually deleting a window. we only need deregistering
  local i = w:id()
  local e = self.entries[i]

  -- force the normal path in :delete
  self.entries[i] = nil

  -- deregister the window
  self:delete(w)
  self:retile(cur)

  if e then
    for k, _ in pairs(e.tabs) do
      self.windows[k].space = nxt
    end
  end

  if str then
    local o = Mouse.getRelativePosition()
    local p = Geometry.rect(w:zoomButtonRect()):move({ -1, -1 }).topleft

    EventTap.event.newMouseEvent(
      EventTap.event.types.leftMouseDown, p):post()

    -- only for me
    EventTap.keyStroke({ 'ctrl' }, str)

    Timer.doAfter(0.5, function()
      EventTap.event.newMouseEvent(
        EventTap.event.types.leftMouseUp, p):post()

      Mouse.setRelativePosition(o)

      -- revert back
      self.entries[i] = e

      -- register the window and skip the tab handling
      -- but we still need to set the frame for the tab
      self:insert(w,   nxt)
      self:retile(nxt, window)
    end)

  else
    self.entries[i] = e

    self:insert(w,   nxt)
    self:retile(nxt, window)
  end
end

function _M:jump(i)
  local w = Window.focusedWindow()
  local s = Spaces.focusedSpace()

  if not w or not s then
    return
  end

  local l = Spaces.spacesForScreen(w:screen())

  if not l then
    return
  end

  self:move(w, s, l[i], tostring(i))
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

  local i, _ = get_index(Spaces.spacesForScreen(c), function(v)
    return v == s
  end)

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
