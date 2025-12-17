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


-- xwm
hs.loadSpoon('XWM'):start():bindHotkeys({
  reinit      = { { 'ctrl',  'alt' }, 'r'      },
  retile      = { { 'ctrl',  'alt' }, 't'      },

  swap_prev   = { { 'ctrl',  'alt' }, 'up'     },
  swap_next   = { { 'ctrl',  'alt' }, 'down'   },
  swap_master = { { 'ctrl',  'alt' }, 'return' },

  skid        = { { 'ctrl',  'alt' }, 'tab'    },

  prev        = { { 'shift', 'alt' }, 'tab'    },
  next        = { {          'alt' }, 'tab'    },

  jump_1      = { { 'ctrl',  'alt' }, '1'      },
  jump_2      = { { 'ctrl',  'alt' }, '2'      },
  jump_3      = { { 'ctrl',  'alt' }, '3'      },
  jump_4      = { { 'ctrl',  'alt' }, '4'      },
  jump_5      = { { 'ctrl',  'alt' }, '5'      },
  jump_6      = { { 'ctrl',  'alt' }, '6'      },
  jump_7      = { { 'ctrl',  'alt' }, '7'      },
  jump_8      = { { 'ctrl',  'alt' }, '8'      },
  jump_9      = { { 'ctrl',  'alt' }, '9'      }
})
