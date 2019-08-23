hs.window.animationDuration = 0

-- Window Hints
hs.hints.style = 'vimperator'
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'm', hs.hints.windowHints)

hs.loadSpoon("MiroWindowsManager")
spoon.MiroWindowsManager.sizes = { 6/5, 4/3, 3/2, 2/1, 3/1, 4/1, 6/1 }
spoon.MiroWindowsManager.fullScreenSizes = {1, 6/5, 4/3, 2}
spoon.MiroWindowsManager:bindHotkeys({
  up = {{}, 'c'},
  right = {{}, 'u'},
  down = {{}, 'w'},
  left = {{}, 'h'},
  fullscreen = {{}, 'x'},
  middle ={{}, 'm'}
})

-- Dvorak copy/paste
-- hs.inspect(hs.keycodes.map)
-- Copy (34 = c)
hs.hotkey.bind({'ctrl'}, ',', function() hs.eventtap.keyStroke({'cmd'}, 34) end)
-- Paste (47 = v)
hs.hotkey.bind({'ctrl'}, '.', function() hs.eventtap.keyStroke({'cmd'}, 47) end)
hs.hotkey.bind({'ctrl', 'shift'}, '.', function() hs.eventtap.keyStroke({'cmd', 'alt'}, 47) end)
-- Paste and Match style
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, '.', function() hs.eventtap.keyStroke({'cmd', 'alt', 'shift'}, 47) end)
-- Cut (11 = x)
hs.hotkey.bind({'ctrl'}, ';', function() hs.eventtap.keyStroke({'cmd'}, 11) end)
-- Undo (44 = z)
hs.hotkey.bind({'ctrl'}, 'escape', function() hs.eventtap.keyStroke({'cmd'}, 44) end)
-- Redo (44 = z)
hs.hotkey.bind({'ctrl', 'alt'}, 'escape', function() hs.eventtap.keyStroke({'cmd', 'shift'}, 44) end)

require 'numpad'
require 'reload-config'
require 'ctrlDoublePress'
require 'toggle-app'
-- require 'caffeine'

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 't', toggleTerminal)
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'd', toggleDictionary)
