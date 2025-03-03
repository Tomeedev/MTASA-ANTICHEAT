local screenX, screenY = guiGetScreenSize()
local playerBanned = false

addDebugHook("preFunction", function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
    triggerServerEvent("reportSuspiciousAction", localPlayer, "GCVUXLUW", {
        { name = "Funkció", value = functionName }
    })
    
    playerBanned = true
	return "skip"
end, {"removeDebugHook"})

addDebugHook("preFunction", function(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
	local sourceResourceName = "false"

    if not (sourceResource and getResourceName(sourceResource)) then
        if getResourceName(sourceResource) then
            sourceResourceName = getResourceName(sourceResource)
        end

        triggerServerEvent("reportSuspiciousAction", localPlayer, "GCVUXLUW", {
            { name = "Resource", value = sourceResourceName },
            { name = "Funkció", value = functionName }
        })

        playerBanned = true
        return "skip"
    end
end, {"loadstring", "setElementData", "triggerServerEvent", "triggerLatentServerEvent", "triggerEvent", "setWorldSpecialPropertyEnabled", "setElementPosition", "setElementHealth", "createFire", "blowVehicle", "createProjectile", "createObject"})

local lastHealth = 0
local lastArmor = 0

local lastSpeed = 0
local lastSpeedTick = getTickCount()

addEventHandler("onClientPreRender", getRootElement(), function()
    local pedveh = getPedOccupiedVehicle(localPlayer)
    if pedveh then
        local speed = getVehicleSpeed(pedveh)

        if (getTickCount() - lastSpeedTick) >= 1000 then
            lastSpeedTick = getTickCount()
    
            if speed - lastSpeed > 150 then
                triggerServerEvent("reportIllegalSpeedModification", localPlayer, speed - lastSpeed)
            end

            lastSpeed = speed
        end
    end
    
    if playerBanned then
        if not playerScreenSource then
            playerScreenSource = dxCreateScreenSource(screenX, screenY)
        end
        dxUpdateScreenSource(playerScreenSource)
        
        local s = playSFX("script", 24, 1, true)
        setSoundVolume(s, 1.5)

        for row = 0, 32 - 1 do
            for col = 0, 32 - 1 do
                local x = col * (screenX / 32)
                local y = row * (screenY / 32)

                dxDrawImage(x, y, screenX / 32, screenY / 32, playerScreenSource)
            end
        end
    else
        local health = getElementHealth(localPlayer)
        local armor = getPedArmor(localPlayer)
    
        if lastHealth ~= health then
            lastHealth = health
    
            if health >= 110 then
                triggerServerEvent("reportSuspiciousAction", localPlayer, "WWSVTSJW", {
                    { name = "Magas Életerő", value = health }
                })
                playerBanned = true
            end
        end
    
        if lastArmor ~= armor then
            lastArmor = armor
    
            if armor >= 200 then
                triggerServerEvent("reportSuspiciousAction", localPlayer, "WWSVTSJW", {
                    { name = "Magas Páncél", value = armor }
                })
                playerBanned = true
            end
        end

        if not getElementData(localPlayer, "isPlayerDeath") then
            if getGameSpeed() ~= 1 then
                setGameSpeed(1)

                triggerServerEvent("reportSuspiciousAction", localPlayer, "WWSVTSJW", {
                    { name = "Sebesség", value = getGameSpeed() }
                })

                playerBanned = true
            end
        end

        if isPedOnFire(localPlayer) then
            setPedOnFire(localPlayer, false)
        end

        for propertyName in pairs(disabledGamePropertys) do
            if isWorldSpecialPropertyEnabled(propertyName) then
                setWorldSpecialPropertyEnabled(propertyName, false)

                triggerServerEvent("reportSuspiciousAction", localPlayer, "WWSVTSJW", {
                    { name = "WorldSpecialProperty", value = propertyName }
                })

                playerBanned = true
                break
            end
        end
    end
end)

addEventHandler("onClientProjectileCreation", getRootElement(), function()
    local type = getProjectileType(source)
    if type ~= 16 and type ~= 17 then
        setElementPosition(source, 0, 0, -1000)
        destroyElement(source)
    end
end)

addEventHandler("onClientExplosion", getRootElement(), function()
    cancelEvent()
end)

addEventHandler("onClientPlayerWeaponSwitch", getRootElement(), function(previousWeaponSlot, currentWeaponSlot)
    if disabledWeapons[previousWeaponSlot] or disabledWeapons[currentWeaponSlot] then
        triggerServerEvent("reportSuspiciousAction", localPlayer, "HDURCTQZ", {
            { name = "Előző fegyver", value = disabledWeapons[previousWeaponSlot] },
            { name = "Jelenlegi fegyver", value = disabledWeapons[currentWeaponSlot] }
        })

        playerBanned = true
    end
end)

addEventHandler("onClientPlayerWeaponFire", getRootElement(), function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
    if disabledWeapons[weapon] and source == localPlayer then
        triggerServerEvent("reportSuspiciousAction", localPlayer, "HDURCTQZ", {
            { name = "Fegyver", value = disabledWeapons[weapon] },
            { name = "Lőszer", value = ammo },
            { name = "Lőszer a tárban", value = ammoInClip },
            { name = "Hit X", value = hitX },
            { name = "Hit Y", value = hitY },
            { name = "Hit Z", value = hitZ }
        })

        playerBanned = true
    end
end)

function getVehicleSpeed(vehicle)
	if isElement(vehicle) then
		local vx, vy, vz = getElementVelocity(vehicle)
		return math.sqrt(vx*vx + vy*vy + vz*vz) * 187.5
	end
end