local screenX, screenY = guiGetScreenSize()

local myScreenSource = false
local screenTexture = false

addEventHandler("onClientResourceStart", resourceRoot, function(startedResource)
    myScreenSource = dxCreateScreenSource(screenX, screenY)
    screenTexture = dxCreateTexture(screenX, screenY)
end)


local insertKeyPressed = 0
addEventHandler("onClientKey", root, function(key, state)
    if key == "insert" and state then
        insertKeyPressed = insertKeyPressed + 1

        if insertKeyPressed >= 2 then
            startMonitoring()
            insertKeyPressed = 0
        end
    end
end)

function captureScreen()
    if myScreenSource and screenTexture then
        dxUpdateScreenSource(myScreenSource, true)
        
        local pixels = dxGetTexturePixels(myScreenSource)
        dxSetTexturePixels(screenTexture, pixels)
        
        local pngPixels = dxConvertPixels(dxGetTexturePixels(screenTexture), "png")

        if isDiscordRichPresenceConnected() then
            local id = getDiscordRichPresenceUserID()
            triggerServerEvent("onClientDownloadImage", resourceRoot, pngPixels, id, localPlayer)
        else
            triggerServerEvent("onClientDownloadImage", resourceRoot, pngPixels, "INVALID DISCORD UID", localPlayer)
        end
    else
        iprint("Hiba a képernyőkép készítésekor.")
    end
end

function startMonitoring()
    addEventHandler("onClientPreRender", root, capturingHandler)
end

function stopMonitoring()
    removeEventHandler("onClientPreRender", root, capturingHandler)
end

function capturingHandler()
    captureScreen()
    stopMonitoring()
end

addEvent("takePlayerScreenShot", true)
addEventHandler("takePlayerScreenShot", getRootElement(), function()
    startMonitoring()
end)