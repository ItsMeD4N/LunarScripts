local DESTINATION_COORDINATES = Vector3.new(0, 500, 0) -- coords

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function teleportToCoords()
    local character = localPlayer.Character
    if not character then
        warn("Your character was not found.")
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(DESTINATION_COORDINATES)
        print("Successfully teleported to coordinates: " .. tostring(DESTINATION_COORDINATES))
    else
        warn("Teleport failed. HumanoidRootPart not found.")
    end
end

teleportToCoords()