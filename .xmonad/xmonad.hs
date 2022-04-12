import XMonad

import XMonad.Actions.CycleWS
import XMonad.Actions.CycleWindows
-- import XMonad.Actions.MouseResize
-- import XMonad.Actions.WorkspaceNames

-- import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName

-- import XMonad.Layout.BorderResize
-- import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.Gaps
import XMonad.Layout.Grid
import XMonad.Layout.IndependentScreens
import XMonad.Layout.MultiColumns
import XMonad.Layout.ResizableTile
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.Spacing
-- import XMonad.Layout.WindowArranger

import XMonad.Util.Cursor
import XMonad.Util.Run

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified Data.List       as L

-- import System.Environment
-- import System.Exit

-- import Graphics.X11.ExtraTypes.XF86


-- userLayout = mouseResize $ borderResize $ windowArrange $ avoidStruts $ gaps [(U, 2), (D, 2), (L, 2), (R, 2)] $ spacing 2 $
userLayoutHook =
    avoidStruts $ gaps [(U, 4), (D, 4), (L, 4), (R, 4)] $ spacing 4 $
        tile        |||
--      emptyBSP    |||
--      Mirror tile |||
        horiz       |||
        multi       |||
        Grid        |||
        Full

    where
        tile  = mouseResizableTile {
            masterFrac    = 0.62,
            fracIncrement = 0.02,
            draggerType   = BordersDragger
        }
        horiz = tile {
            isMirrored    = True
        }
--      tile  = ResizableTall 1 0.02 0.62 []
        multi = multiCol  [1] 2 0.02 0.62


userManageHook =
    composeOne [
        isDialog                     -?> doSpecialFloat,
        isFullscreen                 -?> doFullFloat,
--      className =? "Eog"           -?> doFloat,
        className =? "zoom"          -?> doFloat,
        className =? "Totem"         -?> doFloat,
        className =? "Steam"         -?> doFloat,
--      className =? "Evince"        -?> doFloat,
        className =? "VirtualBox"    -?> doFloat,
        className =? "TopLevelShell" -?> doFloat
--      className =? "ROOT"          -?> doFloat,
--      className =? "Gmrun"         -?> doSpecialFloat,
--      className =? "R_x11"         -?> doFloat,
--      className =? "Gnuplot"       -?> doFloat,
--      name      ~? "Style Manager" -?> doFloat,
--      command   ~? "mathematica"   -?> doFloat,
    ] <+> manageDocks

    where
--      q ~? x  = fmap (L.isInfixOf x) q
--      name    = stringProperty "WM_NAME"
--      command = stringProperty "WM_COMMAND"
        doSpecialFloat =
            doFloatDep (\ (W.RationalRect _ _ w h) -> W.RationalRect (0.5 - w/2) (0.62 - h/2) w h)


userHandleEventHook =
    docksEventHook <+> fullscreenEventHook


userKeys conf@(XConfig {XMonad.modMask = mod}) =
    M.fromList $ [
--      ((mod1Mask,         xK_Tab                 ), cycleRecentWindows [xK_Alt_L] xK_Tab xK_Control_L),
--      ((0,                xF86XK_AudioPause      ), safeSpawn "pactl" ["set-sink-mute",   "0", "toggle"]),
--      ((0,                xF86XK_AudioLowerVolume), safeSpawn "pactl" ["set-sink-volume", "0", "-5%"]),
--      ((0,                xF86XK_AudioRaiseVolume), safeSpawn "pactl" ["set-sink-volume", "0", "+5%"]),
--      ((mod .|. mod1Mask, xK_q                   ), io (exitWith ExitSuccess))

        ((mod,              xK_w        ), kill),
        ((mod,              xK_Return   ), windows W.shiftMaster),
        ((mod,              xK_comma    ), sendMessage (IncMasterN   1)),
        ((mod,              xK_period   ), sendMessage (IncMasterN (-1))),
        ((mod,              xK_d        ), withFocused $ windows . W.sink),
        ((mod,              xK_Left     ), sendMessage Shrink),
        ((mod,              xK_Right    ), sendMessage Expand),
        ((mod,              xK_Up       ), sendMessage MirrorExpand),
        ((mod,              xK_Down     ), sendMessage MirrorShrink),
        ((mod,              xK_space    ), sendMessage NextLayout),
        ((mod,              xK_Page_Up  ), windows W.focusUp),
        ((mod,              xK_Page_Down), windows W.focusDown),
        ((mod1Mask,         xK_Tab      ), windows W.focusDown),

        ((0,                xK_Print    ), safeSpawn     "gnome-screenshot" ["-i"]),
        ((mod .|. mod1Mask, xK_x        ), safeSpawnProg "gnome-terminal"),
        ((mod .|. mod1Mask, xK_Page_Up  ), windows W.swapUp),
        ((mod .|. mod1Mask, xK_Page_Down), windows W.swapDown),
        ((mod .|. mod1Mask, xK_Tab      ), shiftNextScreen),
        ((mod .|. mod1Mask, xK_space    ), setLayout $ XMonad.layoutHook conf),
        ((mod .|. mod1Mask, xK_p        ), restart "xmonad" True),
        ((mod .|. mod1Mask, xK_q        ), safeSpawn "gnome-session-quit" ["--force", "--no-prompt", "--logout"]),
        ((mod .|. mod1Mask, xK_s        ), safeSpawn "gnome-session-quit" ["--force", "--no-prompt", "--power-off"]),
        ((mod .|. mod1Mask, xK_r        ), safeSpawn "gnome-session-quit" ["--force", "--no-prompt", "--reboot"])

    ] ++ [
        ((mod .|. m, k), windows $ onCurrentScreen f i) |
            (i, k) <- zip (workspaces' conf) $ [xK_1 .. xK_9] ++ [xK_0],
            (f, m) <- [(W.view, 0), (W.shift, mod1Mask)]
    ]
--  ++ [
--      ((mod .|. m, k), screenWorkspace s >>= flip whenJust (windows . f)) |
--          (k, s) <- zip [xK_F1 .. xK_F6] [0 ..],
--          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
--  ]


userMouses (XConfig {XMonad.modMask = mod}) =
    M.fromList $ [
        ((mod, button1), (\w -> focus w >> mouseMoveWindow   w >> windows W.shiftMaster)),
        ((mod, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)),
        ((mod, button2), (\w -> focus w >> windows W.shiftMaster)),
        ((mod, button4), (\w -> focus w >> shiftToPrev)),
        ((mod, button5), (\w -> focus w >> shiftToNext))
    ]


-- userLogHook h =
--     dynamicLogWithPP $ userPP h
--
--     where
--         userPP h = defaultPP {
--             ppSep             = "  ",
--             ppVisible         =  id,
--             ppHidden          =  id,
--             ppHiddenNoWindows =  const " ",
--             ppUrgent          =  const "",
--             ppLayout          =  const "",
--             ppOrder           = \(w: _: t: _) -> [w, t],
--             ppOutput          =  hPutStrLn h,
--             ppTitle           =  shorten 96
--         }
userLogHook = return ()


userStartupHook = do
    setDefaultCursor xC_left_ptr
    setWMName     "LG3D"
    safeSpawnProg "wmreg"


userClientMask =
    enterWindowMask        .|.
    propertyChangeMask     .|.
    structureNotifyMask


userRootMask =
    enterWindowMask        .|.
    leaveWindowMask        .|.
    buttonPressMask        .|.
    structureNotifyMask    .|.
    substructureNotifyMask .|.
    substructureRedirectMask


userHandleExtraArgs xs conf =
    case xs of
        [] -> return conf
        _  -> fail $ "unrecognized flags " ++ show xs


main = do
--  h <- spawnPipe "dzen2"
    n <- countScreens

    xmonad $ docks $ ewmh XConfig {
        normalBorderColor  = "#1c1c1c",
        focusedBorderColor = "#303030",
        terminal           = "gnome-terminal",
        layoutHook         =  userLayoutHook,
        manageHook         =  userManageHook,
        handleEventHook    =  userHandleEventHook,
        workspaces         =  workspaces n $ [1 .. 9] ++ [0],
        modMask            =  mod4Mask,
        keys               =  userKeys,
        mouseBindings      =  userMouses,
        borderWidth        =  0,
        logHook            =  userLogHook,
        startupHook        =  userStartupHook,
        focusFollowsMouse  =  True,
        clickJustFocuses   =  False,
        clientMask         =  userClientMask,
        rootMask           =  userRootMask,
        handleExtraArgs    =  userHandleExtraArgs
    }

    where
        workspaces n a = [marshall s w | s <- [0 .. (n - 1)], w <- map show a]
