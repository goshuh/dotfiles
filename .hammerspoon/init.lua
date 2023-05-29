local Application = require 'hs.application'
local EventTap    = require 'hs.eventtap'
local Hotkey      = require 'hs.hotkey'
local Socket      = require 'hs.socket'
local Spaces      = require 'hs.spaces'
local Task        = require 'hs.task'
local Timer       = require 'hs.timer'
local Window      = require 'hs.window'


Hotkey.alertDuration     = 0
Window.animationDuration = 0


-- launchers
function launch(app, ...)
    Task.new('/usr/bin/open', nil, {'-a', app, '--args', ...}):start()
end

Hotkey.bind('alt', 'e', function() Application.launchOrFocus('Finder'           ) end)
Hotkey.bind('alt', 'a', function() Application.launchOrFocus('Firefox'          ) end)
Hotkey.bind('alt', 'z', function() Application.launchOrFocus('Microsoft Outlook') end)
Hotkey.bind('alt', 's', function() Application.launchOrFocus('CotEditor'        ) end)
Hotkey.bind('alt', 'x', function() Application.launchOrFocus('iTerm'            ) end)

Hotkey.bind('alt', 't', function() launch('TradingView',
    '--proxy-server=192.168.192.1:3168'
) end)


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


--[[
-- sending Window to other spaces
function moveWindowToSpace(n)
    local win = Window.focusedWindow()

    if not win or not win:isStandard() or win:isFullScreen() then
        return
    end

    -- the canonical way of getting spaces
    --   spaces.spaceForScreen(Window:screen())
    -- doesn't work on ventura 13.2.1
    Spaces.moveWindowToSpace(win, n)

    -- gc-friendly
    win = nil
end

Hotkey.bind('ctrl-alt', '1', 'Move window to space 1', function() moveWindowToSpace(1) end)
-- i don't know what's going on, but this works
Hotkey.bind('ctrl-alt', '2', 'Move window to space 2', function() moveWindowToSpace(3) end)
Hotkey.bind('ctrl-alt', '3', 'Move window to space 3', function() moveWindowToSpace(4) end)
Hotkey.bind('ctrl-alt', '4', 'Move window to space 4', function() moveWindowToSpace(5) end)
Hotkey.bind('ctrl-alt', '5', 'Move window to space 5', function() moveWindowToSpace(6) end)
Hotkey.bind('ctrl-alt', '6', 'Move window to space 6', function() moveWindowToSpace(7) end)
--]]

-- maximize when creating and quit when closing the last Window
local whitelist = {
    -- no suiside after closing the console
    ['Hammerspoon'] = true,
    -- unstable after killed and restarted multiple times
    ['Finder'     ] = true
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
        if whitelist[name] then
            return
        end

        Timer.doAfter(1, function ()
            local app = win:application()

            if app and app:isRunning() then
                -- not only in the current space
                local tmp = Window.filter.new(name)

                -- the only window from all desktops
                if not next(tmp:getWindows()) then
                    app:kill()
                end
            end
        end)
    end
})


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

    sock:connect(yabai):write(mesg, function ()
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


-- mouse wheel
-- this stuff works, but it also makes the scroll lagging
--[[
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