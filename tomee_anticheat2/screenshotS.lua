addCommandHandler("ascreenshot", function(sourcePlayer, commandName, targetPlayer)
    if getElementData(sourcePlayer, "acc.adminLevel") >= 10 then
        if not (targetPlayer) then
            outputChatBox("[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 255, 150, 0, true)
        else
            targetPlayer, targetName = exports.seal_core:findPlayer(sourcePlayer, targetPlayer)

            if targetPlayer then
                triggerClientEvent(targetPlayer, "takePlayerScreenShot", sourcePlayer)
            end
        end
    end
end)

local lastScreenShot = {}

addEvent("onClientDownloadImage", true)
addEventHandler("onClientDownloadImage", resourceRoot, function(pixels, discordID, player, reason)
    if lastScreenShot[client] and getTickCount() - lastScreenShot[client] < 10000 then
        return
    else
        lastScreenShot[client] = getTickCount()
    end

    if pixels then
        local photo = encodeString("base64", pixels)
        local ID = '7b5088b5356757c'

        local sendOptions = {
            method = "POST",
            headers = {
                ["Authorization"] = "Client-ID " .. ID, 
                ["Content-Type"] = "multipart/form-data"
            },
            formFields = {
                ["image"] = photo,
                ["type"] = "base64"
            }
        }

        fetchRemote("https://api.imgur.com/3/upload", sendOptions, function(response, info)
            if response then
                local callback = fromJSON(response)
                if callback and callback.success then
                    local imgurLink = callback.data.link
                    local currentTime = os.date("%d/%m/%Y %H:%M:%S")
                    local description
                    if isElement(player) then
                        description = string.format('Játékos részletei\n```yaml\nSerial: %s\nIP: %s\nNév: %s\nFiók: %s\n```',
                            getPlayerSerial(player),
                            getPlayerIP(player),
                            getPlayerName(player),
                            getAccountName(getPlayerAccount(player)) or 'Vendég'
                        )
                    else
                        description = "A játékos már nem elérhető."
                    end

                    local discordData = {
                        username = "Kalo Bone Ügyfélszolgálatos",

                        embeds = {{
                            title = ":shield: ANTICHEAT - REPORT",
                            description = description,
                            color = 3323583,
                            
                            fields = {
                                {
                                    name = ":frame_photo: **Képernyőkép**",
                                    value = "[Kattints ide, hogy megnézd az Imgur-on](" .. imgurLink .. ")",
                                    inline = true
                                },
                                {
                                    name = "A felhasználó Discord-ja: ",
                                    value = "<@!" .. discordID .. ">",
                                    inline = true
                                },
                                {
                                    name = ":calendar: **Dátum/idő**",
                                    value = currentTime,
                                    inline = false
                                }
                            },

                            image = {
                                url = imgurLink 
                            },

                            thumbnail = {
                                url = imgurLink 
                            }
                        }}
                    }

                    local jsonData = toJSON(discordData)
                    jsonData = string.sub(jsonData, 2, #jsonData - 1)

                    local discordOptions = {
                        method = "POST",
                        headers = {
                            ["Content-Type"] = "application/json"
                        },
                        postData = jsonData
                    }
                    fetchRemote("https://discord.com/api/webhooks/1333917326231474237/lqfYWyw5t0Bmci9nzTP-Cra5ZNIt8SJRi54Z7JeYTUhbmHWfipg0H38dRMWv5b9w7zyW", discordOptions, function(response)
                    end)
                end
            end
        end)
    end
end)