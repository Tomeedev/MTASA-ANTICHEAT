local anticheatWebhooks = {
    ["HDURCTQZ"] = "https://discord.com/api/webhooks/1333905096974532719/UtJ__qCngzfAa7Vq2kocq6maMwkXqHvVZu8wc0BYmI_UAbGeYx2bk09zYWr4PHavhCLg",
    ["DCSVWGNE"] = "https://discord.com/api/webhooks/1333899950098092082/xTRmw0Qy0i_YFPKahWxXrE3-iYBEBHPdBAH4jeqV0MgZqQNHiAc8VdD2RFrnUQ_n6mpz",
    ["WWSVTSJW"] = "https://discord.com/api/webhooks/1333903025248403567/GiwmUHFWTrtts-YRF4t5ajGN-I2lqLTJfi_LxZ9lgR9sDOQy5_t_HsWQU5l0qgIebSMX",
    ["GCVUXLUW"] = "https://discord.com/api/webhooks/1333908209357947022/eJdEXgYcPVHSe91n79KTodLaLhPEwkcAAlMrtE_UNoyTjmyyoPmBnrJDyn-9YMWLJOEn",
    ["YWMLRYLB"] = "https://discord.com/api/webhooks/1333910495652216903/_djWtUnM_OH1qbea3SwgMDVYJVc5IQctrorezkRAeWeWb3Hvdfwwl-YS-kk38n116THP",
    ["RPZGOBJL"] = "https://discord.com/api/webhooks/1333912759624011877/71ILfU6rq42KtjYF2cPtz3dSErRjRRMrrKrWwo3EYNAOj3Pq-xT6kVDZUBKqnb9HMjxb"
}

local lastSpeedModification = {}

addEvent("reportIllegalSpeedModification", true)
addEventHandler("reportIllegalSpeedModification", getRootElement(), function(speed)
    if (lastSpeedModification[client] and lastSpeedModification[client] - getTickCount() > 1000) or not lastSpeedModification[client] then
        for k, v in pairs(getElementsByType("player")) do
            local admin = getElementData(v, "acc.adminLevel") or 0

            if admin >= 7 then
                outputChatBox("#32ba9d[SealMTA]: #ffffffHirtelen sebesség változás érzékelve! #248570(" .. speed .. " km/h)", v, 255, 255, 255, true)
                outputChatBox("#32ba9d[SealMTA]: #ffffffJátékos NÉV | ID: #248570" .. getPlayerName(client):gsub("_", " ") .. " (" .. getElementData(client, "playerID") .. ")", v, 255, 255, 255, true)
            end
        end

        sendAntiCheatMessage("https://discord.com/api/webhooks/1333911103633100920/2O9s5HZoDAx4QSz_vq-55M_dOKeybm0vkGIoFxGQpmt4Bm7vhcsJBE8dNJg_BgvRjz_Q", "Hirtelen sebességváltozás", {
            { name = "Játékos Neve", value = getPlayerName(client), inline = true },
            { name = "Játékos Serialja", value = getPlayerSerial(client), inline = true },
            { name = "Játékos IP címe", value = getPlayerIP(client), inline = true },
            { name = "Sebesség", value = math.floor(speed), inline = true },
            { name = "Dátum", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false }
        })
    end
end)

local managementSerials = {
    ["8FD57B3846E681B0DB4244DF4A5230E4"] = true, -- balage
    ["0EB993DA466366F4F7A9DE8AD585B391"] = true, -- erxk
    ["AC224757ECF1FABAE6C7319C5935F153"] = true, -- babi
    ["F3CC810EBBD9521110CEE17D97FC3F13"] = true, -- szylard
    ["F3C797821A9E2E392AEDEDE582526884"] = true, -- marci
}

addEventHandler("onElementDataChange", getRootElement(), function(dataName, oldValue, newValue)
    local validDataChange = true
    local sourceElementType = getElementType(source)

    if client then
        if not enabledElementDatas.ignored[dataName] then
            validDataChange = false

            if enabledElementDatas.player[dataName] and client == source then
                validDataChange = true
            elseif enabledElementDatas.vehicle[dataName] and sourceElementType == "vehicle" and getPedOccupiedVehicle(client) and getPedOccupiedVehicle(client) == source then
                validDataChange = true
            elseif string.find(dataName, "border") then
                validDataChange = true
            end
        end
    end

    if not validDataChange then
        local sourceElementName = ((sourceElementType == "player" and getPlayerName(source)) or sourceElementType)
        local sourceElementSerial = ((sourceElementType == "player" and getPlayerSerial(source)) or sourceElementType)
        local sourceElementIP = ((sourceElementType == "player" and getPlayerIP(source)) or sourceElementType)

        triggerEvent("reportSuspiciousAction", client, "DCSVWGNE", {
            { name = "SourceElement", value = sourceElementName },
            { name = "Serial", value = sourceElementSerial },
            { name = "IP", value = sourceElementIP },
            { name = "DataName", value = dataName },
            { name = "OldValue", value = inspect(oldValue) },
            { name = "NewValue", value = inspect(newValue) }
        })

        setElementData(source, dataName, oldValue)
        cancelEvent()
    end

    local isPlayerElement = getElementType(source) == "player"
    local isAdminData = dataName == "acc.adminLevel"

    if isPlayerElement and isAdminData then
        local playerSerial = getPlayerSerial(source)
        local playerPassed = true

        if playerSerial then
            local checkManagementPermissionLevel = newValue > 7 and not managementSerials[playerSerial]
            local checkManagementPermissionUnlimited = newValue > 12 and not managementSerials[playerSerial]

            if checkManagementPermissionLevel or checkManagementPermissionUnlimited then
                playerPassed = false
            end

            if not playerPassed then
                setElementData(source, "acc.adminLevel", 0)
            end
        end
    end
end)

addEventHandler("onPlayerTriggerEventThreshold", getRootElement(), function()
    triggerEvent("reportSuspiciousAction", source, "HDURCTQZ", {})
end)

addEvent("reportSuspiciousAction", true)
addEventHandler("reportSuspiciousAction", getRootElement(), function(anticheatReason, actionData)
    if not client then
        client = source
    end

    local defaultEmbedFields = {
        { name = "Játékos Neve", value = getPlayerName(client), inline = true },
        { name = "Játékos Serialja", value = getPlayerSerial(client), inline = true },
        { name = "Játékos IP címe", value = getPlayerIP(client), inline = true },
    }

    if #actionData > 0 then
        for i = 1, #actionData do
            table.insert(defaultEmbedFields, { name = actionData[i].name, value = inspect(actionData[i].value), inline = true })
        end
    end
    table.insert(defaultEmbedFields, { name = "Dátum", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false })

    for _, playerElement in pairs(getElementsByType("player")) do
        local adminLevel = getElementData(playerElement, "acc.adminLevel") or 0

        if adminLevel >= 7 then
            exports.seal_gui:showInfobox(playerElement, "i", getPlayerName(client):gsub("_", " ") .. " szétlett nyalatva az anticheat által.")
        end
    end

    banPlayer(client, true, false, true, "Kalo Bone Ügyfélszolgálatos", anticheatReason)
    sendAntiCheatMessage(anticheatWebhooks[anticheatReason], anticheatKickReasons[anticheatReason], defaultEmbedFields)
end)

addEventHandler("onPlayerJoin", getRootElement(), function()
    local source = source
    local sourceIp = getPlayerIP(source)

    fetchRemote("http://proxy.mind-media.com/block/proxycheck.php?ip=" .. sourceIp, function(responseData, responseError)
		if responseError == 0 then
			if responseData == "Y" then
                triggerEvent("reportSuspiciousAction", source, "RPZGOBJL", {})
            end
        end
    end)
end)

function sendAntiCheatMessage(webhook, message, embedFields)
    local sendOptions = {
        username = "Kalo Bone Ügyfélszolgálatos",
        embeds = {
            {
                title = "ANTICHEAT - REPORT",
                description = message,
                color = 3323583,
                fields = embedFields
            }
        }
    }

    local jsonData = toJSON(sendOptions)
    jsonData = string.sub(jsonData, 2, #jsonData - 1)

    local discordOptions = {
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json"
        },

        postData = jsonData
    }

    fetchRemote(webhook, discordOptions, function(response) end)
end

local discordWebhookTypes = {
    moneylog = {"moneylog", "https://discord.com/api/webhooks/1333926594301136999/ERX89sywmXyxVS7T8XaEWbOkhMM8nO_ljihageYOD62VNMKlgP1kCQpDxL6J0FuZdEHR"},
    adminlog = {"adminlog", "https://discord.com/api/webhooks/1333926532141551716/aJvhKhd3UXoi6eRuMyuHoky8ODtDQmE95ggyEYzjT4SYLDmBM_Jbm3lXNW3GkUqrJGju"},
    givelog = {"givelog", "https://discord.com/api/webhooks/1333926478114455672/0WaIXSfm3sbHpE1riJ18AmShASopEq2gpaBeJtgPYBsihYBUOWkeB33NkvuSeWdVKWyH"},
    icjail = {"icjail", "https://discord.com/api/webhooks/1333926632121041018/FrUqAsheGdH7Qhn45Fmo3osPA2WdoBA321VzACaCWj8oc9RHVB5850D3Igi1Cje7caCA"},

    itemlog = {"itemlog", "https://discord.com/api/webhooks/1333919875810197607/fPYDOza7nx-JnzYL02K2cPLMGlYlCev5rZ_6r8qk1lpESUUkQoY1xIP4z0dKGoH1tnJF"},
    ooclog = {"ooclog", "https://discord.com/api/webhooks/1333919711662047314/W7ShJRVSbwQQTCXqfnewlowil2trsIOOsreSjWaRqWos82eTYh1q2wcJotbOk2qfYVjD"},
    rplog = {"rplog", "https://discord.com/api/webhooks/1333919615654432979/sLwr72ZEylV9WhTWMPQhWrBnB0HHABZj7loQ4PbfrGv7GS9ESJU7ZpNlg5xb-qmogx94"},
    adminreplies = {"adminreplies", "https://discord.com/api/webhooks/1333921174488481802/91NQrglHG9Jmy5dhix7LIkVSL-jhgCAOsr8s--rrhGekHa3WoRhaKL9GZdqIJbnJI7zx"},
    casino = {"casino", "https://discord.com/api/webhooks/1333919757233160273/tbfbG3apQEAIGx1N9VviVjTwQR5bwjtOfP7PACtxOnvWW13mwcQUhkLLPZgYeE6UGB-n"},
    contract = {"contract", "https://discord.com/api/webhooks/1333919812539121775/vWzm-NpTjRa-5UicHmuoxUnuvWs_yCBW9deRP0pj5T99wqrM6R0ntcLsO0H3851nKqfy"},
    giveitem = {"giveitem", "https://discord.com/api/webhooks/1333921090103410803/tMzq0K9-sizTsAIAA7oaqxck01JV-MHClJqNY66Z55eXWfS5A2LryJsqA5j9meiokene"},
    ajail = {"ajail", "https://discord.com/api/webhooks/1333921218398650419/l1dnMxeGBc3BKiIn3q9D3SeYBnudRV20cd2_6_i6rCCkWZqXH7eIGbqNXGi_5TCmB9AT"},
    setpp = {"setpp", "https://discord.com/api/webhooks/1333921328109195386/0dUpkpuVA43ER_tprRh6EtUnjudIvqgTj7AP5NWDHlJkQMCfW9MDnaP48N1xsc7R6XjD"},
    setmoney = {"setmoney", "https://discord.com/api/webhooks/1333921439157325835/wIFFZs5sV6CNzeXFphjjKRVZC9hrAYfNTlhdpaxS4nUAiVE1gv1clC0qTgcd1QG0sTpt"},
    makeveh = {"makeveh", "https://discord.com/api/webhooks/1333922671360217118/2DH2TgCGJ8FxT62noQJl6-KNjX_sSfEypFMV2e0xpi3mBMI_d0AuCdiEngtRiocic1qx"}
}
    
function sendDiscordMessage(message, type)
    if type == "ac2" then
        createLog("acwebhook", message)
    end
    if not discordWebhookTypes[type][2] then
        return print("nemjo webhook")
    end
sendOptions = {
    formFields = {
        content=""..message..""
    },
}
fetchRemote ( discordWebhookTypes[type][2], sendOptions, WebhookCallback )
end

function WebhookCallback(responseData) 
    --outputDebugString("(Discord webhook callback): responseData: "..responseData)
end

addCommandHandler("listacbans", function(sourcePlayer)
    if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
        outputChatBox("[SealMTA]: #ffffffÖsszes AC által kitiltott játékos:", sourcePlayer, 60, 184, 130, true)

        local bans = getBans()

        if #bans > 0 then
            for banId, ban in pairs(bans) do
                outputChatBox(" (" .. banId .. ")#ffffff:", sourcePlayer, 60, 184, 130, true)
                
                outputChatBox("     Player banned: #ffffff" .. (getBanNick(ban) or "nil"), sourcePlayer, 60, 184, 130, true)
                outputChatBox("     Banned by: #ffffff" .. (getBanAdmin(ban) or "nil"), sourcePlayer, 60, 184, 130, true)
                outputChatBox("     IP: #ffffff" .. (getBanIP(ban) or "nil"), sourcePlayer, 60, 184, 130, true)
                outputChatBox("     Serial: #ffffff" .. (getBanSerial(ban) or "nil"), sourcePlayer, 60, 184, 130, true)
                outputChatBox("     Reason: #ffffff" .. (getBanReason(ban) or "nil"), sourcePlayer, 60, 184, 130, true)
            end
        else
            outputChatBox(" - Nincs egy sem!", sourcePlayer, 60, 184, 130, true)
        end
    end
end)

addCommandHandler("banac", function(sourcePlayer, commandName, targetPlayer, ...)
    if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
        if (targetPlayer) then
            local targetPlayer = getPlayerFromName(targetPlayer)
            local reason = table.concat({...}, " ")

            if targetPlayer then
                local targetPlayerSerial = getPlayerSerial(targetPlayer)
                local targetPlayerIP = getPlayerIP(targetPlayer)

                if reason and reason ~= "" then
                    banPlayer(targetPlayer, true, false, true, "Kalo Bone Ügyfélszolgálatos", "AC: " .. reason)
                    outputChatBox("[SealMTA]: #ffffffSikeresen kitiltottad a játékost!", sourcePlayer, 60, 184, 130, true)
                else
                    outputChatBox("[SealMTA]: #ffffff/" .. commandName .. " [Játékos] [Indok]", sourcePlayer, 60, 184, 130, true)
                end
            else
                outputChatBox("[SealMTA]: #ffffffNem található játékos!", sourcePlayer, 243, 90, 90, true)
            end
        else
            outputChatBox("[SealMTA]: #ffffff/" .. commandName .. " [Játékos] [Indok]", sourcePlayer, 60, 184, 130, true)
        end
    end
end)

addCommandHandler("unbanac", function(sourcePlayer, commandName, serial)
    if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
        if (serial) then
            local foundBan = false

            local bans = getBans()
            for banId, ban in pairs(bans) do
                if getBanSerial(ban) == serial then
                    foundBan = ban
                    break
                end
            end

            if foundBan then
                outputChatBox("[SealMTA]: #ffffffSikeresen feloldottad a kitiltást!", sourcePlayer, 60, 184, 130, true)
                removeBan(foundBan, sourcePlayer)
            else
                outputChatBox("[SealMTA]: #ffffffNem található kitiltás!", sourcePlayer, 243, 90, 90, true)
            end
        else
            outputChatBox("[SealMTA]: #ffffff/" .. commandName .. " [SERIAL]", sourcePlayer, 60, 184, 130, true)
        end
    end
end)