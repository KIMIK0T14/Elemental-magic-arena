-- KIMIKO BETA - Funciones de Combate (NO OBFUSCAR)
-- code.lua
-- Este archivo contiene las funciones criticas que interactuan con los RemoteEvents
-- NO pasar por obfuscador, cargar junto con combat.lua obfuscado

local CombatFunctions = {}

-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Funcion para disparar Chaotic Dragon
function CombatFunctions.fireChaos(targetPosition)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local dragon = char:FindFirstChild("Chaotic Dragon", true)
    if not dragon then return false end
    
    local event = dragon:FindFirstChild("Event", true)
    if not event then return false end
    
    local success = pcall(function()
        event:FireServer("FIRE_ATTACK", targetPosition)
    end)
    
    return success
end

-- Funcion para disparar Fire GreatSword Q
function CombatFunctions.fireQ()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local sword = char:FindFirstChild("Fire GreatSword")
    if not sword then return false end
    
    local qevent = sword:FindFirstChild("Qevent")
    if not qevent then return false end
    
    local success = pcall(function()
        qevent:FireServer()
    end)
    
    return success
end

-- Funcion para disparar Fire GreatSword X
function CombatFunctions.fireX(targetPosition)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local sword = char:FindFirstChild("Fire GreatSword")
    if not sword then return false end
    
    local xevent = sword:FindFirstChild("Xevent")
    if not xevent then return false end
    
    local success = pcall(function()
        xevent:FireServer(targetPosition)
    end)
    
    return success
end

-- Funcion para obtener HumanoidRootPart de un jugador
function CombatFunctions.getHRP(player)
    if not player or not player.Character then return nil end
    return player.Character:FindFirstChild("HumanoidRootPart")
end

-- Funcion para obtener Humanoid de un jugador
function CombatFunctions.getHumanoid(player)
    if not player or not player.Character then return nil end
    return player.Character:FindFirstChildOfClass("Humanoid")
end

-- Funcion para verificar si tiene Chaotic Dragon
function CombatFunctions.hasChaos()
    local char = LocalPlayer.Character
    if not char then return false end
    return char:FindFirstChild("Chaotic Dragon", true) ~= nil
end

-- Funcion para verificar si tiene Fire GreatSword
function CombatFunctions.hasFireSword()
    local char = LocalPlayer.Character
    if not char then return false end
    return char:FindFirstChild("Fire GreatSword") ~= nil
end

-- Exportar al global para que combat.lua pueda usarlo
_G.KimikoCombat = CombatFunctions

return CombatFunctions
