hl.config({
  general = {
    border_size                 =  0,

    gaps_in                     =  4,
    gaps_out                    =  8,
    gaps_workspaces             =  0,

    layout                      = 'master',

    no_focus_fallback           =  true,

    resize_on_border            =  true,
    extend_border_grab_area     =  8,

    allow_tearing               =  false,

    resize_corner               =  0
  },

  decoration = {
    inactive_opacity            =  0.8,

    dim_modal                   =  false,
    dim_special                 =  1.0,

    shadow = {
      enabled                   =  false
    },

    blur = {
      size                      =  16,
      passes                    =  3,

      noise                     =  0.0,
      contrast                  =  1.0,
      brightness                =  1.0,
      vibrancy                  =  0.0,
      vibrancy_darkness         =  1.0
    }
  },

  input = {
    repeat_delay                =  400,
    accel_profile               = 'adaptive',

    scroll_method               = '2fg',

    mouse_refocus               =  false,
    float_switch_override_focus =  2,
    special_fallthrough         =  true
  },

  group = {
    groupbar = {
      enabled                   =  false
    }
  },

  misc = {
    disable_hyprland_logo       =  true,
    disable_splash_rendering    =  true,

    force_default_wallpaper     =  0,

    allow_session_lock_restore  =  true,
    session_lock_xray           =  true,

    background_color            = '#23272e'
  },

  binds = {
    ignore_group_lock           =  true,

    movefocus_cycles_fullscreen =  true
  },

  opengl = {
    nvidia_anti_flicker         =  false
  },

  ecosystem = {
    no_update_news              =  true,
    no_donation_nag             =  true
  },

  master = {
    mfact                       =  0.64,
    new_status                  = 'inherit',

    orientation                 = 'left'
  }
})


hl.animation({
  leaf    = 'global',
  enabled =  true,
  speed   =  2,
  bezier  = 'default'
})

hl.animation({
  leaf    = 'windows',
  enabled =  true,
  speed   =  2,
  bezier  = 'default',
  style   = 'popin 80%'
})

hl.animation({
  leaf    = 'workspaces',
  enabled =  true,
  speed   =  2,
  bezier  = 'default',
  style   = 'fade'
})


hl.env('XCURSOR_SIZE', '18')

hl.on('hyprland.start', function()
  hl.exec_cmd('/home/gosh/.local/src/bin/init')
end)


hl.bind('SUPER + W',            hl.dsp.window.close())

hl.bind('SUPER + Return',       hl.dsp.layout('swapwithmaster master'))
hl.bind('SUPER + Comma',        hl.dsp.layout('addmaster'))
hl.bind('SUPER + Period',       hl.dsp.layout('removemaster'))
hl.bind('SUPER + F',            hl.dsp.window.float({ action = 'toggle' }))
hl.bind('SUPER + Left',         hl.dsp.layout('mfact -0.01'))
hl.bind('SUPER + Right',        hl.dsp.layout('mfact +0.01'))
hl.bind('SUPER + Up',           hl.dsp.layout('cycleprev'))
hl.bind('SUPER + Down',         hl.dsp.layout('cyclenext'))

hl.bind('SUPER + ALT + Up',     hl.dsp.layout('swapprev'))
hl.bind('SUPER + ALT + Down',   hl.dsp.layout('swapnext'))

hl.bind('SUPER + ALT + Q',      hl.dsp.exit())
hl.bind('SUPER + ALT + P',      hl.dsp.exec_raw('systemctl poweroff'))
hl.bind('SUPER + ALT + R',      hl.dsp.exec_raw('systemctl reboot'))

hl.bind('SUPER + X',            hl.dsp.exec_raw('ghostty'))
hl.bind('SUPER + E',            hl.dsp.exec_raw('nautilus'))
hl.bind('SUPER + A',            hl.dsp.exec_raw('firefox'))

hl.bind('SUPER + Q',            hl.dsp.global('quickshell:picker'))
hl.bind('SUPER + ALT + L',      hl.dsp.global('quickshell:locker'))
hl.bind('SUPER + ALT + D',      hl.dsp.dpms('on'))

hl.bind('Print',                hl.dsp.global('quickshell:shoter'))
hl.bind('XF86AudioRaiseVolume', hl.dsp.global('quickshell:incvol'))
hl.bind('XF86AudioLowerVolume', hl.dsp.global('quickshell:decvol'))
hl.bind('XF86AudioMute',        hl.dsp.global('quickshell:mute'))

hl.bind('SUPER + mouse:272',    hl.dsp.window.drag(),   { mouse = true })
hl.bind('SUPER + mouse:273',    hl.dsp.window.resize(), { mouse = true })


hl.layer_rule({
  name  = 'quickshell',
  match = {
    namespace = 'quickshell-default'
  },
  blur        = true,
  blur_popups = true
})

hl.window_rule({
  name  = 'waydroid',
  match = {
    class = 'Waydroid'
  },
  float = true
})


-- vdesk
local vdesk_mon_fake = {}
local vdesk_mon_real = {}
local vdesk_wid_max  = 0

function vdesk_init()
  local M = hl.get_monitors()
  local W = hl.get_workspaces()

  vdesk_mon_fake = {}
  vdesk_mon_real = {}
  vdesk_wid_max  = 0

  for i, m in ipairs(M) do
    local f = i
    local r = m.id

    vdesk_mon_fake[f] = {
      id = r,
      ws = {}
    }
    vdesk_mon_real[r] = f
  end

  for i, w in ipairs(W) do
    if w.id > vdesk_wid_max then
      vdesk_wid_max = w.id
    end

    local m = 1 + (i - 1) % #M
    local a = vdesk_mon_fake[m]

    a.ws[#a.ws + 1] = w.id

    hl.workspace_rule({
      workspace  = tostring(w.id),
      monitor    = tostring(a.id),
      persistent = true
    })
  end

  vdesk_jump(1)
end

function vdesk_news(f, n)
  vdesk_wid_max = vdesk_wid_max + 1

  local a = vdesk_mon_fake[f]
  local w = vdesk_wid_max

  a.ws[#a.ws + 1] = w

  hl.workspace_rule({
    workspace  = tostring(w),
    monitor    = tostring(a.id),
    persistent = true
  })

  return w
end

function vdesk_jump_fake(f, n)
  local a = vdesk_mon_fake[f]
  local w = n <= #a.ws and a.ws[n] or vdesk_news(f, n)

  hl.dispatch(hl.dsp.focus({
    monitor = a.id
  }))

  hl.dispatch(hl.dsp.focus({
    workspace          = tostring(w),
    on_current_monitor = true
  }))
end

function vdesk_move_fake(f, n)
  local a = vdesk_mon_fake[f]
  local w = n <= #a.ws and a.ws[n] or vdesk_news(f, n)

  hl.dispatch(hl.dsp.window.move({
    workspace = tostring(w),
    follow    = false
  }))
end

function vdesk_jump(n)
  local c = hl.get_monitor('current')

  if not c then
    return
  end

  local d = vdesk_mon_real[c.id]
  local p = hl.get_cursor_pos()

  for f, _ in pairs(vdesk_mon_fake) do
    if f ~= d then
      vdesk_jump_fake(f, n)
    end
  end

  vdesk_jump_fake(d, n)

  hl.dispatch(hl.dsp.cursor.move(p))
end

function vdesk_move(n)
  local c = hl.get_monitor('current')

  if not c then
    return
  end

  vdesk_move_fake(vdesk_mon_real[c.id], n)
end

hl.on('hyprland.start',   vdesk_init)
hl.on('monitor.added',    vdesk_init)
hl.on('monitor.removed',  vdesk_init)
hl.on('config.reloaded',  vdesk_init)

for i = 1, 10 do
  hl.bind('SUPER + '       .. tostring(i % 10), function()
    vdesk_jump(i)
  end)

  hl.bind('SUPER + ALT + ' .. tostring(i % 10), function()
    vdesk_move(i)
  end)
end
