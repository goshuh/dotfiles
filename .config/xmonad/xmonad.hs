import XMonad

import XMonad.Actions.CycleWS
import XMonad.Actions.CycleWindows

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName

import XMonad.Layout.Gaps
import XMonad.Layout.Grid
import XMonad.Layout.MultiColumns
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.Spacing

import XMonad.Util.Cursor
import XMonad.Util.Run

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified Data.Monoid     as D


userLayoutHook =
    avoidStruts $ gaps [(U, 4), (D, 4), (L, 4), (R, 4)] $ spacing 4 $
        vert ||| hori ||| mult ||| Grid ||| Full

    where
        vert = mouseResizableTile {
            masterFrac    = 0.62,
            fracIncrement = 0.02,
            draggerType   = BordersDragger
        }
        hori = vert {
            isMirrored    = True
        }
        mult = multiCol [1] 2 0.02 0.62


userManageHook =
    composeOne [
        isDialog                     -?> doSpecialFloat,
        isFullscreen                 -?> doFullFloat,
        className =? "zoom"          -?> doFloat,
        className =? "Totem"         -?> doFloat,
        className =? "VirtualBox"    -?> doFloat,
        className =? "TopLevelShell" -?> doFloat
    ] <+> manageDocks

    where
        doSpecialFloat =
            doFloatDep (\ (W.RationalRect _ _ w h) ->
                W.RationalRect (0.5 - w/2) (0.62 - h/2) w h)


userHandleEventHook _ = return (D.All True)


userKeys conf@(XConfig {XMonad.modMask = mod}) =
    M.fromList $ [
        ((mod,              xK_w        ), kill),
        ((mod,              xK_Return   ), windows        W.shiftMaster),
        ((mod,              xK_comma    ), sendMessage $  IncMasterN   1),
        ((mod,              xK_period   ), sendMessage $  IncMasterN (-1)),
        ((mod,              xK_d        ), withFocused $  windows . W.sink),
        ((mod,              xK_Left     ), sendMessage    Shrink),
        ((mod,              xK_Right    ), sendMessage    Expand),
        ((mod,              xK_space    ), sendMessage    NextLayout),
        ((mod,              xK_Page_Up  ), windows        W.focusUp),
        ((mod,              xK_Page_Down), windows        W.focusDown),
        ((mod1Mask,         xK_Tab      ), windows        W.focusDown),

        ((0,                xK_Print    ), safeSpawn     "gnome-screenshot" ["-i"]),
        ((mod .|. mod1Mask, xK_x        ), safeSpawnProg "gnome-terminal"),
        ((mod .|. mod1Mask, xK_Page_Up  ), windows        W.swapUp),
        ((mod .|. mod1Mask, xK_Page_Down), windows        W.swapDown),
        ((mod .|. mod1Mask, xK_Tab      ), shiftNextScreen),
        ((mod .|. mod1Mask, xK_space    ), setLayout   $  XMonad.layoutHook conf),
        ((mod .|. mod1Mask, xK_p        ), restart       "xmonad" True),
        ((mod .|. mod1Mask, xK_q        ), safeSpawn     "gnome-session-quit" ["--force", "--no-prompt", "--logout"]),
        ((mod .|. mod1Mask, xK_s        ), safeSpawn     "gnome-session-quit" ["--force", "--no-prompt", "--power-off"]),
        ((mod .|. mod1Mask, xK_r        ), safeSpawn     "gnome-session-quit" ["--force", "--no-prompt", "--reboot"])

    ] ++ [
        ((mod .|. m, k), windows $ f i) |
            (i, k) <- zip (workspaces conf) num,
            (f, m) <- [(W.greedyView, 0), (W.shift, mod1Mask)]
    ] ++ [
        ((mod .|. m, k), screenWorkspace s >>= flip whenJust (windows . f)) |
            (k, s) <- zip fn [0 ..],
            (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]

    where
        num = [xK_1  .. xK_9]  ++ [xK_0]
        fn  = [xK_F1 .. xK_F9] ++ [xK_F10]


userMouses (XConfig {XMonad.modMask = mod}) =
    M.fromList $ [
        ((mod, button1), (\w -> focus w >> mouseMoveWindow   w >> windows W.shiftMaster)),
        ((mod, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)),
        ((mod, button2), (\w -> focus w >> windows W.shiftMaster)),
        ((mod, button4), (\w -> focus w >> shiftToPrev)),
        ((mod, button5), (\w -> focus w >> shiftToNext))
    ]


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
    xmonad $ docks . ewmhFullscreen . ewmh $ XConfig {
        normalBorderColor  = "#1c1c1c",
        focusedBorderColor = "#303030",
        terminal           = "gnome-terminal",
        layoutHook         =  userLayoutHook,
        manageHook         =  userManageHook,
        handleEventHook    =  userHandleEventHook,
        workspaces         =  map show $ [1 .. 9] ++ [0],
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
        handleExtraArgs    =  userHandleExtraArgs,
        extensibleConf     =  M.empty
    }
