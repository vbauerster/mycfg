-- local log = hs.logger.new("numpad", "info")

-- hs.inspect(hs.keycodes.map)
local npad = {}

npad[19] = 'pad7'
npad[20] = 'pad5'
npad[21] = 'pad3'
npad[23] = 'pad1'
npad[22] = 'pad9'
npad[26] = 'pad0'
npad[28] = 'pad2'
npad[25] = 'pad4'
npad[29] = 'pad6'
npad[27] = 'pad8'

local modalKey = hs.hotkey.modal.new({'ctrl', 'alt', 'cmd'}, 'n', 'Npad on')
local doExit = function()
    modalKey:exit()
    hs.alert.show('Npad off', 0.5)
end
modalKey:bind({}, 'escape', doExit)

local exitTimer = hs.timer.delayed.new(4, doExit)

modalKey:bind({'ctrl', 'alt', 'cmd'}, 'n', function() exitTimer:start() end)

function modalKey:entered()
    exitTimer:start()
end

function modalKey:exited()
    if exitTimer:running() then
        exitTimer:stop()
    end
end

for k, v in pairs(npad) do
    modalKey:bind({}, k, function()
        -- Pressed:
        hs.eventtap.event.newKeyEvent({}, v, true):post()
    end, function()
        -- Released:
        hs.eventtap.event.newKeyEvent({}, v, false):post()
        exitTimer:start()
    end, function()
        -- Repeat:
        hs.eventtap.event.newKeyEvent({}, v, true):setProperty(hs.eventtap.event.properties.keyboardEventAutorepeat, 1):post()
        exitTimer:start()
    end)
end

-- https://github.com/Hammerspoon/hammerspoon/issues/1499
local foo = hs.distributednotifications.new(
    function(name, object, userInfo)
        -- print("notification: " .. name .. "\n")
        local currentLayout = hs.keycodes.currentLayout()
        hs.alert.show(currentLayout)
    end,
    -- or 'AppleSelectedInputSourcesChangedNotification'
    'com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged'
)
foo:start()
