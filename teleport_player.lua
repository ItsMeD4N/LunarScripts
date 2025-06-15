local TARGET_USERNAME = "TargetPlayerName"

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local targetPlayer = Players:FindFirstChild(TARGET_USERNAME)

local function teleportToPlayer()
    if not targetPlayer then
        warn("Player with username '" .. TARGET_USERNAME .. "' was not found in this server.")
        return
    end

    if targetPlayer == localPlayer then
        warn("You cannot teleport to yourself.")
        return
    end

    print("Target found: " .. targetPlayer.Name)

    local myCharacter = localPlayer.Character
    local targetCharacter = targetPlayer.Character

    if not myCharacter or not targetCharacter then
        warn("Character not found. Waiting for characters to spawn...")
        return
    end

    local myRootPart = myCharacter:FindFirstChild("HumanoidRootPart")
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")

    if myRootPart and targetRootPart then
        myRootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 5, 0)
        print("Successfully teleported to " .. targetPlayer.Name)
    else
        warn("Teleport failed. HumanoidRootPart not found.")
    end
end

teleportToPlayer()