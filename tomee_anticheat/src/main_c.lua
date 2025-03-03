--tomeedev.hu
--Tomee

local debug = addDebugHook("preFunction", function(resource, functionName, _, fileName, fileNumber, ...)
    local args = {...}
    local resourceName = getResourceName(resource)
    if fileName == '[string "?"]' and fileNumber == 0 then
        local information = "["..resourceName.."] \nLuaCode: "..functionName.."("..inspect(args):gsub("{", ""):gsub("}", "")
        if not triggerServerEvent("anticheat:allEvents", localPlayer, "onPlayerBan", "Lua Injector "..information) then crashPlayer() end
        return "skip"
    end
end, {
    "outputChatBox",
    "addDebugHook",
    "triggerServerEvent",
    "triggerLatentServerEvent",
    "removeDebugHook",
    "setElementHealth",
    "createProjectile",
    "setPedArmor",
})

setTimer(function()
    if not debug then
        if not triggerServerEvent("anticheat:allEvents", localPlayer, "onPlayerBan", "Break Debug Hook") then crashPlayer() end
    end
end, 1000, 0)

addEventHandler("onClientResourceStop", root, function(res)
    local resName = getResourceName(res)
    setTimer(function()
        if not triggerServerEvent("anticheat:allEvents", localPlayer, "onResourceCheck", resName) then crashPlayer() end
    end, 5000, 1)
end)

function crashPlayer()
    for i=1, 5000 do
        setTimer(function()
            for i=1, 5000 do
                print("Hello, World!")
            end
        end, 0, 0)
    end
end