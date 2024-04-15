local AXUiElem  = require 'hs.axuielement'
local FnUtils   = require 'hs.fnutils'
local Geometry  = require 'hs.geometry'
local Inspect   = require 'hs.inspect'
local Screen    = require 'hs.screen'
local Spaces    = require 'hs.spaces'
local Spoons    = require 'hs.spoons'
local Timer     = require 'hs.timer'
local Window    = require 'hs.window'


-- bad
Window.animationDuration = 0


local _M = {
    gap     =  8,
    ratio   =  0.64,
    quit    =  true,
    enable  =  false,
    staged  =  false,

    screen  =  nil,
    filter  =  nil,
    window  =  nil,

    spaces  =  {},

    name    = 'XWM',
    version = '0.1',
    author  = 'gosh',
    license = 'None'
}

_M.__index = _M


local function in_array(arr, val)
    for i, v in ipairs(arr) do
        if v == val then
            return i
        end
    end

    return nil
end

local function rm_array(arr, val)
    local index = 0

    for i, v in ipairs(arr) do
        if v == val then
            index = i
            break
        end
    end

    if index > 0 then
        table.remove(arr, index)
    end
end


function _M:init()
    self.enable = true

    if not self.screen then
        self.screen = Screen.watcher.new(function()
            self.staged = false
            self:reinit()
        end)
        self.screen:start()
    end

    return self:reinit()
end

function _M:reinit()
    if self.staged then
        return self
    end

    self.staged = true

    if not self.filter then
        self.filter = Window.filter.new():setOverrideFilter({
            visible      =  true,
            hasTitlebar  =  true,
            fullscreen   =  false,
            allowRoles   = 'AXStandardWindow'
        })
    end

    if not self.window then
        self.window = Window.filter.copy(self.filter):setOverrideFilter({
            currentSpace =  true
        })
    end

    self.spaces = {}

    for _, screen in ipairs(Screen.allScreens()) do
        local frame = screen:frame()

        frame.x = frame.x + self.gap
        frame.y = frame.y + self.gap
        frame.w = frame.w - self.gap * 2
        frame.h = frame.h - self.gap * 2

        for _, space in ipairs(Spaces.spacesForScreen(screen)) do
            self.spaces[space] = {
                windows = {},
                frame   = frame
            }
        end
    end

    return self
end

function _M:deinit()
    self.enable = false
    self.staged = false

    self.screen = nil
    self.filter = nil
    self.window = nil

    self.spaces = {}

    return self
end

function _M:start()
    self:init()

    for _, window in ipairs(self.filter:getWindows()) do
        self:insert(window)
    end

    for space, _ in pairs(self.spaces) do
        self:tile(space)
    end

    self.filter:subscribe({
        Window.filter.windowVisible,
        Window.filter.windowNotVisible,
        Window.filter.windowFullscreened,
        Window.filter.windowUnfullscreened,
    }, function (win, _, evt)
        self:handler(win, evt)
    end)

    return self
end

function _M:stop()
    self.screen:stop()
    self.filter:unsubscribeAll()

    return self:deinit()
end

function _M:bindHotkeys(mapping)
    local spec = {
        toggle      = FnUtils.partial(self.toggle, self),
        tile        = FnUtils.partial(self.tile,   self),

        swap_prev   = FnUtils.partial(self.swap,   self, -1),
        swap_next   = FnUtils.partial(self.swap,   self,  1),
        swap_master = FnUtils.partial(self.swap,   self,  0),

        skid        = FnUtils.partial(self.skid,   self),
    }

    for i = 1, 10 do
        spec['jump_' .. tostring(i)] = FnUtils.partial(self.jump, self, i)
    end

    Spoons.bindHotkeysToSpec(spec, mapping)

    return self
end

function _M:toggle()
    return self.enable and self:stop() or self:start()
end

function _M:handler(window, event)
    if not window then
        return
    end

    local space = Spaces.windowSpaces(window)[1]

    if event == 'windowVisible' or
       event == 'windowUnfullscreened' then
        space = self:insert(window)
    end

    if event == 'windowNotVisible' or
       event == 'windowFullscreened' then
        space = self:delete(window)
    end

    self:tile(space)
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

function _M:tile(space)
    if not space then
        space = Spaces.focusedSpace()
    end

    local sinfo = self.spaces[space]

    if not sinfo or Spaces.spaceType(space) ~= 'user' then
        return
    end

    -- filter
    local wins = {}

    for _, window in ipairs(sinfo.windows) do
        if window:application() then
            table.insert(wins, window)
        end
    end

    sinfo.windows = wins

    for i, window in ipairs(wins) do
        local frame = self:layout(wins, i, sinfo.frame)

        -- see: https://github.com/Hammerspoon/hammerspoon/issues/3224
        local elem  = AXUiElem.applicationElement(window:application())
        local eui   = elem.AXEnhancedUserInterface

        if eui then
            elem.AXEnhancedUserInterface = false
        end

        window:setFrame(frame, 0)

        if eui then
            elem.AXEnhancedUserInterface = true
        end
    end
end

local whitelist = {
    -- no suiside after closing the console
    ['org.hammerspoon.Hammerspoon'] = true,
    -- unstable after killed and restarted multiple times
    ['com.apple.finder'           ] = true,
    -- long-running stuff
    ['com.cisco.anyconnect.gui'   ] = true,
    ['com.owncloud.desktopclient' ] = true,
    ['com.tencent.xinWeChat'      ] = true,
    ['com.microsoft.Outlook'      ] = true,
    ['com.tinyspeck.slackmacgap'  ] = true
}

function _M:insert(window, space)
    if not window or not window:title() then
        return nil
    end

    if not space then
        space = Spaces.windowSpaces(window)[1]
    end

    if not space then
        space = Spaces.focusedSpace()
    end

    local sinfo = self.spaces[space]

    if not sinfo then
        return nil
    end

    -- the new window is always the master
    table.insert(sinfo.windows, 1, window)

    window:focus()

    return space
end

function _M:delete(window, space, skip)
    if not space then
        space = Spaces.windowSpaces(window)[1]
    end

    if not space then
        space = Spaces.focusedSpace()
    end

    local sinfo = self.spaces[space]

    if not sinfo then
        return nil
    end

    rm_array(sinfo.windows, window)

    if not self.quit or skip then
        return space
    end

    local app = window:application()

    if not app then
        return space
    end

    local bid = app:bundleID()

    if whitelist[bid] then
        return space
    end

    Timer.doAfter(3, function ()
        if app and app:isRunning() then
            -- not only in the current space
            for _, win in ipairs(self.filter:getWindows()) do
                if win:application():bundleID() == bid then
                    return
                end
            end

            -- no windows, kill
            app:kill()
        end
    end)

    return space
end

function _M:swap(forward)
    local window = Window.focusedWindow()
    local space  = Spaces.focusedSpace()

    if not window or not space then
        return
    end

    local sinfo = self.spaces[space]

    if not sinfo then
        return
    end

    local index = in_array(sinfo.windows, window)

    if index then
        local jndex = forward == 0 and 1 or forward + index

        if jndex >= 1 and jndex <= #sinfo.windows then
            sinfo.windows[index], sinfo.windows[jndex] =
            sinfo.windows[jndex], sinfo.windows[index]
        end
    end

    self:tile(space)
end

function _M:mainScreen(space)
    -- Screen.mainScreen is not always working correctly
    for _, screen in ipairs(Screen.allScreens()) do
        if screen:getUUID() == Spaces.spaceDisplay(space) then
            return screen
        end
    end

    return Screen.mainScreen()
end

function _M:move(window, curr, next, screen)
    if not next or curr == next then
        return
    end

    self:delete(window, curr, true)
    self:insert(window, next)

    if screen then
        window:moveToScreen(screen, true, false, nil)
    end

    Spaces.moveWindowToSpace(window, next)

    self:tile(curr)
    self:tile(next)
end

function _M:jump(index)
    local window = Window.focusedWindow()
    local space  = Spaces.focusedSpace()

    if not window or not space then
        return
    end

    local list = Spaces.spacesForScreen(self:mainScreen(space))

    if not list then
        return
    end

    self:move(window,
              space,
              list[index])
end

function _M:skid()
    local window = Window.focusedWindow()
    local space  = Spaces.focusedSpace()

    if not window or not space then
        return
    end

    local curr  = self:mainScreen(space)
    local next  = curr:next()
    local list  = Spaces.spacesForScreen(next)

    if curr == next or not list then
        return
    end

    local index = in_array(Spaces.spacesForScreen(curr), space)

    if not index then
        return
    end

    self:move(window,
              space,
              list[index],
              next)
end


return _M
