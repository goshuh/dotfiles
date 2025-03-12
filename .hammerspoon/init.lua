-- local Host        = require 'hs.host'
-- local Socket      = require 'hs.socket'
-- local Spaces      = require 'hs.spaces'
-- local Task        = require 'hs.task'

local Application = require 'hs.application'
local Hotkey      = require 'hs.hotkey'
local Timer       = require 'hs.timer'
local Window      = require 'hs.window'
local Mouse       = require 'hs.mouse'
local EventTap    = require 'hs.eventtap'


--[[
-- launchers
function launch(app, ...)
    Task.new('/usr/bin/open', nil, {'-a', app, '--args', ...}):start()
end

function launchWithRoot(...)
    Task.new('/usr/bin/osascript', nil, {'-e', string.format('do shell script "%s" with administrator privileges', table.concat({...}, ' '))}):start()
end
--]]

Hotkey.alertDuration = 0

Hotkey.bind('alt', 'e', function() Application.launchOrFocus('Finder'            ) end)
Hotkey.bind('alt', 'a', function() Application.launchOrFocus('Firefox'           ) end)
Hotkey.bind('alt', 'z', function() Application.launchOrFocus('Microsoft Outlook' ) end)
Hotkey.bind('alt', 's', function() Application.launchOrFocus('Sublime Text'      ) end)
Hotkey.bind('alt', 'x', function() Application.launchOrFocus('iTerm'             ) end)
Hotkey.bind('alt', 'c', function() Application.launchOrFocus('Visual Studio Code') end)

--[[
-- mount tmpfs
function createTmpFS(dir, mb)
    local info = Host.volumeInformation()

    if info[dir] then
        return
    end

    -- really mount
    launchWithRoot('mount_tmpfs', '-s' .. tostring(mb) .. 'M', dir)
end

Hotkey.bind('ctrl-alt', 'r', function() createTmpFS('/tmp/ram', 8192) end)
--]]


--[[
-- alt-tab
Window.switcher.ui.highlightColor        = {0.4, 0.4, 0.4}
Window.switcher.ui.backgroundColor       = {0.9, 0.9, 0.9}
Window.switcher.ui.showTitles            =  false
Window.switcher.ui.showSelectedTitle     =  false
Window.switcher.ui.showThumbnails        =  false
Window.switcher.ui.showSelectedThumbnail =  false

local switcher = Window.switcher.new(Window.filter.new():setCurrentSpace(true):setDefaultFilter({}))

Hotkey.bind('alt',       'tab', function() switcher:next()     end)
Hotkey.bind('alt-shift', 'tab', function() switcher:previous() end)
--]]


-- sending Window to other spaces
function moveWindowToSpace(n)
    local win = Window.focusedWindow()

    if not win or not win:isStandard() or win:isFullScreen() then
        return
    end

    --[[
    -- the canonical way of getting spaces
    --   spaces.spaceForScreen(Window:screen())
    -- doesn't work on ventura 13.2.1
    Spaces.moveWindowToSpace(win, n)
    --]]

    -- https://github.com/ianyh/Amethyst/issues/1676
    local geo = win:frame()
    local pos = Mouse.absolutePosition()
    local mov = {
        x = geo.x + geo.w / 2,
        y = geo.y + 5
    }

    -- good (for gc) to bind a name
    local lmd = EventTap.event.newMouseEvent(
                EventTap.event.types.leftMouseDown, mov)
    local lmu = EventTap.event.newMouseEvent(
                EventTap.event.types.leftMouseUp,   mov)

    lmd:post()

    -- there must be something good that we can exploit
    EventTap.keyStroke({ 'ctrl' }, tostring(n))

    lmu:post()

    Mouse.absolutePosition(pos)
end

-- Hotkey.bind('ctrl-alt', '1', 'Move window to space 1', function() moveWindowToSpace(1) end)
-- Hotkey.bind('ctrl-alt', '2', 'Move window to space 2', function() moveWindowToSpace(2) end)
-- Hotkey.bind('ctrl-alt', '3', 'Move window to space 3', function() moveWindowToSpace(3) end)
-- Hotkey.bind('ctrl-alt', '4', 'Move window to space 4', function() moveWindowToSpace(4) end)
-- Hotkey.bind('ctrl-alt', '5', 'Move window to space 5', function() moveWindowToSpace(5) end)
-- Hotkey.bind('ctrl-alt', '6', 'Move window to space 6', function() moveWindowToSpace(6) end)
-- Hotkey.bind('ctrl-alt', '7', 'Move window to space 7', function() moveWindowToSpace(7) end)
-- Hotkey.bind('ctrl-alt', '8', 'Move window to space 8', function() moveWindowToSpace(8) end)
-- Hotkey.bind('ctrl-alt', '9', 'Move window to space 9', function() moveWindowToSpace(9) end)


-- maximize when creating and quit when closing the last Window
local whitelist = {
    -- no suiside after closing the console
    ['org.hammerspoon.Hammerspoon'] = true,
    ['com.amethyst.Amethyst'      ] = true,
    -- unstable after killed and restarted multiple times
    ['com.apple.finder'           ] = true,
    -- long-running stuff
    ['com.cisco.anyconnect.gui'   ] = true,
    ['com.owncloud.desktopclient' ] = true,
    ['com.tencent.xinWeChat'      ] = true,
    ['com.microsoft.Outlook'      ] = true,
    ['com.tinyspeck.slackmacgap'  ] = true
}

local filter = Window.filter.new():setDefaultFilter({})

filter:subscribe({
    --[[
    [Window.filter.windowCreated  ] = function(win, name, evt)
        if win:isMaximizable() then
            win:maximize()
        end
    end,
    --]]

    [Window.filter.windowDestroyed] = function(win, name, evt)
        local app = win:application()

        if not app then
            return
        end

        local bid = app:bundleID()

        if not bid or whitelist[bid] then
            return
        end

        Timer.doAfter(3, function()
            if app and app:isRunning() then
                -- not only in the current space
                for _, w in ipairs(filter:getWindows()) do
                    if w:application():bundleID() == bid then
                        return
                    end
                end

                -- no windows, kill
                app:kill()
            end
        end)
    end
})


--[[
-- interface with yabai
local yabai = string.format("/tmp/yabai_%s.socket", os.getenv("USER"))

function sendToYabai(...)
    local args = table.pack(...)
    local mesg = ''

    for i = 1, args.n, 1 do
        mesg = mesg .. tostring(args[i]) .. string.char(0)
    end
    mesg = string.pack('i4', string.len(mesg) + 1) .. mesg .. string.char(0)

    local sock = Socket.new()

    sock:connect(yabai):write(mesg, function()
        sock:disconnect()
    end)
end

function yabaiInit()
    sendToYabai('config', 'layout',              'bsp')
    sendToYabai('config', 'window_placement',    'second_child')
    sendToYabai('config', 'window_topmost',      'on')

    sendToYabai('config', 'top_padding',         '8')
    sendToYabai('config', 'bottom_padding',      '8')
    sendToYabai('config', 'left_padding',        '8')
    sendToYabai('config', 'right_padding',       '8')
    sendToYabai('config', 'window_gap',          '8')

    sendToYabai('config', 'mouse_modifier',      'fn')
    sendToYabai('config', 'focus_follows_mouse', 'autofocus')
end

Hotkey.bind('ctrl-alt', 'y', yabaiInit)
Hotkey.bind('ctrl-alt', 'e', function() sendToYabai('config',   'layout', 'float') end)
Hotkey.bind('ctrl-alt', 't', function() sendToYabai('window', '--toggle', 'split') end)
Hotkey.bind('ctrl-alt', 'f', function() sendToYabai('window', '--toggle', 'float') end)

Hotkey.bind('ctrl-alt', 'w', function() sendToYabai('window', '--warp',   'north') end)
Hotkey.bind('ctrl-alt', 's', function() sendToYabai('window', '--warp',   'south') end)
Hotkey.bind('ctrl-alt', 'a', function() sendToYabai('window', '--warp',   'west' ) end)
Hotkey.bind('ctrl-alt', 'd', function() sendToYabai('window', '--warp',   'east' ) end)
Hotkey.bind('ctrl-alt', '1', function() sendToYabai('window', '--space',  '1'    ) end)
Hotkey.bind('ctrl-alt', '2', function() sendToYabai('window', '--space',  '2'    ) end)
Hotkey.bind('ctrl-alt', '3', function() sendToYabai('window', '--space',  '3'    ) end)
Hotkey.bind('ctrl-alt', '4', function() sendToYabai('window', '--space',  '4'    ) end)
Hotkey.bind('ctrl-alt', '5', function() sendToYabai('window', '--space',  '5'    ) end)
Hotkey.bind('ctrl-alt', '6', function() sendToYabai('window', '--space',  '6'    ) end)
Hotkey.bind('ctrl-alt', '7', function() sendToYabai('window', '--space',  '7'    ) end)
Hotkey.bind('ctrl-alt', '8', function() sendToYabai('window', '--space',  '8'    ) end)
Hotkey.bind('ctrl-alt', '9', function() sendToYabai('window', '--space',  '9'    ) end)
Hotkey.bind('ctrl-alt', '0', function() sendToYabai('window', '--space',  '10'   ) end)
--]]


--[[
-- xwm
hs.loadSpoon('XWM'):start():bindHotkeys({
    toggle      = { { 'ctrl', 'alt' }, 'e'      },
    tile        = { { 'ctrl', 'alt' }, 'q'      },

    swap_prev   = { { 'ctrl', 'alt' }, 'up'     },
    swap_next   = { { 'ctrl', 'alt' }, 'down'   },
    swap_master = { { 'ctrl', 'alt' }, 'return' },

    skid        = { { 'ctrl', 'alt' }, 'tab'    },

    jump_1      = { { 'ctrl', 'alt' }, '1'      },
    jump_2      = { { 'ctrl', 'alt' }, '2'      },
    jump_3      = { { 'ctrl', 'alt' }, '3'      },
    jump_4      = { { 'ctrl', 'alt' }, '4'      },
    jump_5      = { { 'ctrl', 'alt' }, '5'      },
    jump_6      = { { 'ctrl', 'alt' }, '6'      }
})
--]]


--[[
-- mouse wheel
-- this stuff works, but it also makes the scroll lagging
local continuous = EventTap.event.properties.scrollWheelEventIsContinuous
local delta      = EventTap.event.properties.scrollWheelEventDeltaAxis1

local wheel = EventTap.new({EventTap.event.types.scrollWheel}, function(e)
    if e:getProperty(continuous) == 0 then
        e:setProperty(delta, -e:getProperty(delta))
    end

    return false, ({[0] = e})
end)

wheel:start()

Hotkey.bind('ctrl-alt', 'm', function() print(wheel:isEnabled()) end)
--]]
