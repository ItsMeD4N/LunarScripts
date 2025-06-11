local SPEED = 500 
local player = game:GetService("Players").LocalPlayer

local function setSpeed(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    if humanoid then
        humanoid.WalkSpeed = SPEED
    end
end

player.CharacterAdded:Connect(setSpeed)

if player.Character then
    setSpeed(player.Character)
end
