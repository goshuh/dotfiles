import XMonad

import XMonad.Actions.CycleWS
import XMonad.Actions.CycleWindows

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName

import XMonad.Layout.Grid
import XMonad.Layout.MultiColumns
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing

import XMonad.Util.Run

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified Data.List       as L

import System.Environment
import System.Exit

import Graphics.X11.ExtraTypes.XF86

userKeybind conf @ (XConfig {XMonad.modMask = mod}) = M.fromList $ [
        ((mod1Mask, xK_Tab), cycleRecentWindows [xK_Alt_L] xK_Tab xK_Control_L),
        ((mod, xK_w), kill),
        ((mod, xK_q), safeSpawnProg "gmrun"),
        ((mod, xK_a), safeSpawnProg "chromium"),
        ((mod .|. shiftMask, xK_a), safeSpawnProg "firefox"),
        ((mod, xK_z), safeSpawnProg "thunderbird"),
        ((mod, xK_s), safeSpawnProg "gvim"),
        ((mod, xK_x), safeSpawnProg "gnome-terminal"),
        ((mod, xK_e), safeSpawnProg "spacefm"),
        ((mod, xK_n), safeSpawn "feh" ["--no-fehbg", "--randomize", "--bg-fill", "/home/gosh/.wall"]),
        ((mod, xK_r), safeSpawn "killall" ["-9", "root"]),
        ((mod, xK_p), safeSpawn "gnome-terminal" ["-e", "python"]),
        ((0, xF86XK_AudioPause), safeSpawn "pactl" ["set-sink-mute", "0", "toggle"]),
        ((0, xF86XK_AudioLowerVolume), safeSpawn "pactl" ["set-sink-volume", "0", "-5%"]),
        ((0, xF86XK_AudioRaiseVolume), safeSpawn "pactl" ["set-sink-volume", "0", "+5%"]),
        ((mod, xK_t), withFocused $ windows . W.sink),
        ((mod, xK_Left), sendMessage Shrink),
        ((mod, xK_Right), sendMessage Expand),
        ((mod, xK_Up), sendMessage MirrorExpand),
        ((mod, xK_Down), sendMessage MirrorShrink),
        ((mod, xK_Page_Up), windows W.focusUp),
        ((mod, xK_Page_Down), windows W.focusDown),
        ((mod, xK_Return), windows W.shiftMaster),
        ((mod, xK_comma ), sendMessage (IncMasterN 1)),
        ((mod, xK_period), sendMessage (IncMasterN (-1))),
        ((mod, xK_space ), sendMessage NextLayout),
        ((mod .|. mod1Mask, xK_space ), setLayout $ XMonad.layoutHook conf),
        ((mod .|. mod1Mask, xK_Page_Up), windows W.swapUp),
        ((mod .|. mod1Mask, xK_Page_Down), windows W.swapDown),
        ((mod .|. mod1Mask, xK_p), safeSpawn "gnome-screenshot" ["-i"]),
        ((mod .|. mod1Mask, xK_q), safeSpawn "gnome-session-quit" ["--force", "--no-prompt", "--logout"]),
        ((mod .|. mod1Mask, xK_s), safeSpawn "systemctl" ["poweroff"]),
        ((mod .|. mod1Mask, xK_r), safeSpawn "systemctl" ["reboot"])
    ] ++ [
        ((mod .|. m, k), windows $ f i) |
            (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_6],
            (f, m) <- [(W.view, 0), (W.shift, mod1Mask)]
    ] ++ [
        ((mod .|. m, k), screenWorkspace s >>= flip whenJust (windows . f)) |
            (k, s) <- zip [xK_F1 .. xK_F6] [0 ..],
            (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
    ]

userMouseBind (XConfig {XMonad.modMask = mod}) = M.fromList $ [
        ((mod, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)),
        ((mod, button2), (\w -> focus w >> windows W.shiftMaster)),
        ((mod, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)),
        ((mod, button4), (\w -> focus w >> shiftToPrev)),
        ((mod, button5), (\w -> focus w >> shiftToNext))
    ]

userLayout = avoidStrutsOn [U] $ spacing 2 $ tile ||| Mirror tile ||| multi ||| Grid ||| Full
    where
        tile = ResizableTall 1 0.02 0.64 []
        multi = multiCol [1] 2 0.02 0.64

userHandleEventHook = docksEventHook

userLogHook h = dynamicLogWithPP $ userPP h
    where
        userPP h = def {
            ppSep = "  ",
            ppVisible = id,
            ppHidden = id,
            ppHiddenNoWindows = const " ",
            ppUrgent = const "",
            ppLayout = const "",
            ppOrder = \(w:_:t:_) -> [w,t],
            ppOutput = hPutStrLn h,
            ppTitle = shorten 96
        }

userManageHook = composeOne [
        isDialog -?> doSpecialFloat,
        isFullscreen -?> doFullFloat,
        className =? "Eog" -?> doFloat,
        className =? "ROOT" -?> doFloat,
        className =? "Gmrun" -?> doSpecialFloat,
        className =? "R_x11" -?> doFloat,
        className =? "Totem" -?> doFloat,
        className =? "Evince" -?> doFloat,
        className =? "Gnuplot" -?> doFloat,
        className =? "VirtualBox" -?> doFloat,
        stringProperty "WM_NAME" ~? "Style Manager" -?> doFloat,
        stringProperty "WM_COMMAND" ~? "mathematica" -?> doFloat
    ] <+> manageDocks
    where
        q ~? x = fmap (L.isInfixOf x) q
        doSpecialFloat =
            doFloatDep (\ (W.RationalRect _ _ w h) -> W.RationalRect (0.5 - w/2) (0.64 - h/2) w h)

userStartupHook = setWMName "LG3D" >> gnomeRegister
    where
        gnomeRegister = io $ do
            x <- fmap (lookup "DESKTOP_AUTOSTART_ID") getEnvironment
            whenJust x $ \id -> safeSpawn "dbus-send" [
                    "--session",
                    "--print-reply=literal",
                    "--dest=org.gnome.SessionManager",
                    "/org/gnome/SessionManager",
                    "org.gnome.SessionManager.RegisterClient",
                    "string:XMonad",
                    "string:" ++ id
                ]

userClientMask = structureNotifyMask .|. enterWindowMask .|. propertyChangeMask

userRootMask =  substructureRedirectMask .|. substructureNotifyMask .|. structureNotifyMask .|.
    enterWindowMask .|. leaveWindowMask .|. buttonPressMask

main = do
    h <- spawnPipe "xmobar"
    xmonad XConfig {
        modMask = mod4Mask,
        focusFollowsMouse = True,
        clickJustFocuses = False,
        terminal = "xterm",
        borderWidth = 0,
        normalBorderColor = "#1C1C1C",
        focusedBorderColor = "#303030",
        workspaces = map show [1..6],
        keys = userKeybind,
        mouseBindings = userMouseBind,
        handleEventHook = userHandleEventHook,
        layoutHook = userLayout,
        logHook = userLogHook h,
        manageHook = userManageHook,
        startupHook = userStartupHook,
        clientMask = userClientMask,
        rootMask = userRootMask,
        handleExtraArgs = \xs conf -> case xs of
            [] -> return conf
            _  -> fail ("unrecognized flags: " ++ show xs)
    }
