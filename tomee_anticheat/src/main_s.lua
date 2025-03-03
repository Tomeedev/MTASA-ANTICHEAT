----Tomee------
--tomeedev.hu---

local Config = {}
Config.WebhookURL = ""
Config.PunishType = "KICK" -- LOG_ONLY, BAN, KICK
Config.BannedBy = "Anti-Cheat"
Config.BannedReason = "Cheat Detected"

-- Don't Touch Please.
local isResourceStopped = false
local stoppedResources = {}

addEventHandler("onResourceStop", root, function(res)
    stoppedResources[getResourceName(res)] = true
end)

addEvent("anticheat:allEvents", true)
addEventHandler("anticheat:allEvents", root, function(event, ...)
    if client and source ~= client then
        triggerEvent("anticheat:allEvents", client, "onPlayerBan", "Client~=Source (Source="..getPlayerName(source)..")")
        return
    end
    if event == "onPlayerBan" then
        local information = select(1, ...)
        sendEmbed(source, information)
        if Config.PunishType == "BAN" then
            banPlayer(source, true, false, true, Config.BannedBy, Config.BannedReason)
        elseif Config.PunishType == "KICK" then
            kickPlayer(source, Config.BannedBy, Config.BannedReason)
        end
    elseif event == "onResourceCheck" then
        local currentResource = select(1, ...)
        if stoppedResources[currentResource] then return end
        triggerEvent("anticheat:allEvents", client, "onPlayerBan", "Resource Stop ("..currentResource..")")
    end
end)

function sendEmbed(player, information)
    local playerID = getElementData(player, "playerid") or 0
    local playerName = "["..playerID.."] "..getPlayerName(player)
    local playerAccount = getElementData(player, "account:username") or "Not logged yet."
    local playerIP = getPlayerIP(player)
    local playerSerial = getPlayerSerial(player)
    local sendOptions = {
        content = "@everyone",
        embeds = {
            {
                title = "👀 Anti-Cheat Detected Illegal Activity!",
                color = 0xff0000,
                fields = {
                    {name="Name: ", value="```"..playerName.."```", inline=true},
                    {name="Account: ", value="```"..playerAccount.."```", inline=true},
                    {name="", value="", inline=false},
                    {name="IP: ", value="```"..playerIP.."```", inline=true},
                    {name="Serial: ", value="```"..playerSerial.."```", inline=true},
                    {name="Information:", value="```Reason: "..information.."```", inline=false},
                },
            },
        },
    }
    local jsonData = toJSON(sendOptions):sub(2, -2)
    fetchRemote(Config.WebhookURL, {
        queueName = "o22 Q",
        connectionAttempts = 3,
        connectTimeout = 10000,
        method = "POST",
        headers = {
            ["Content-Type"] = "multipart/form-data",
        },
        formFields = {
            payload_json = jsonData,
        },
    }, function(responseData, response)
        if not response.success then
            print("Error:", response.statusCode, responseData)
        end
    end)
end