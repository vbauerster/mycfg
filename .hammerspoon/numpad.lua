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

local register = function(key)
    local modalKey = hs.hotkey.modal.new({'shift'}, key, 'Npad enter')
    local doExit = function()
        modalKey:exit()
        hs.alert.show('Npad quit', 0.5)
    end
    local exitTimer = hs.timer.delayed.new(5, doExit)
    modalKey:bind({}, 'escape', doExit)
    function modalKey:entered()
        exitTimer:start()
        hs.eventtap.keyStroke({}, npad[key])
    end
    function modalKey:exited()
        if exitTimer:running() then
            exitTimer:stop()
        end
    end

    for k, v in pairs(npad) do
        modalKey:bind({'shift'}, k, function()
            -- Pressed:
            exitTimer:start()
            hs.eventtap.event.newKeyEvent({}, v, true):post()
        end, function()
            -- Released:
            hs.eventtap.event.newKeyEvent({}, v, false):post()
        end, function()
            -- Repeat:
            hs.eventtap.event.newKeyEvent({}, v, true):setProperty(hs.eventtap.event.properties.keyboardEventAutorepeat, 1):post()
        end)
        modalKey:bind({}, k, function()
            -- Pressed:
            exitTimer:start()
            hs.eventtap.event.newKeyEvent({}, v, true):post()
        end, function()
            -- Released:
            hs.eventtap.event.newKeyEvent({}, v, false):post()
        end, function()
            -- Repeat:
            hs.eventtap.event.newKeyEvent({}, v, true):setProperty(hs.eventtap.event.properties.keyboardEventAutorepeat, 1):post()
        end)
    end
    return modalKey
end

local modals = {}

if hs.keycodes.currentLayout() == "PDvorak" then
    for k, v in pairs(npad) do
            modals[k] = register(k)
    end
end

-- https://github.com/Hammerspoon/hammerspoon/issues/1499
local foo = hs.distributednotifications.new(
    function(name, object, userInfo)
        -- print("notification: " .. name .. "\n")
        local currentLayout = hs.keycodes.currentLayout()
        if currentLayout == "PDvorak" then
            for k, v in pairs(npad) do
                if modals[k] == nil then
                    modals[k] = register(k)
                end
            end
        else
            for k, v in pairs(modals) do
                if v ~= nil then
                    v:exit()
                    v:delete()
                    modals[k] = nil
                end
            end
        end
        hs.alert.show(currentLayout)
    end,
    -- or 'AppleSelectedInputSourcesChangedNotification'
    'com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged'
)
foo:start()

-- local update = function()
--     local currentLayout = hs.keycodes.currentLayout()
--     if currentLayout == "PDvorak" then
--         -- log.i("OK PDvorak")
--         for k, v in pairs(npad) do
--             if modals[k] == nil then
--                 modals[k] = register(k)
--             end
--         end
--     else
--         -- log.i("NOT PDvorak")
--         for k, v in pairs(modals) do
--             if v ~= nil then
--                 v:delete()
--                 modals[k] = nil
--             end
--         end
--     end
--     hs.alert.show(currentLayout)
-- end
-- hs.keycodes.inputSourceChanged(update)
-- update()

