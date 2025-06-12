local FLY_TOGGLE_KEY = Enum.KeyCode.F   
local FLY_SPEED = 150                 
local SPEED_TOGGLE_KEY = Enum.KeyCode.G
local NORMAL_SPEED = 16                 
local FAST_SPEED = 500                 
local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local isFlying = false
local isFast = false
local bodyGyro, bodyVelocity


local function stopFly()
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    bodyGyro, bodyVelocity = nil, nil
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        humanoid.PlatformStand = false
        if isFast then
            humanoid.WalkSpeed = FAST_SPEED
        else
            humanoid.WalkSpeed = NORMAL_SPEED
        end
    end
    isFlying = false
end

local function startFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    stopFly()
    
    local rootPart = char.HumanoidRootPart
    local humanoid = char.Humanoid
    
    humanoid.PlatformStand = true

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 50000
    bodyGyro.Parent = rootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart

    isFlying = true
end

local function toggleSpeed()
    isFast = not isFast
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        if isFast then
            humanoid.WalkSpeed = FAST_SPEED
        else
            humanoid.WalkSpeed = NORMAL_SPEED
        end
    end
end

runService.RenderStepped:Connect(function()
    if isFlying and bodyGyro and bodyVelocity then
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        
        local moveDirection = Vector3.new(0, 0, 0)
        if uis:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection + Vector3.new(0, -1, 0) end

        if moveDirection.Magnitude > 0 then
            bodyVelocity.Velocity = (workspace.CurrentCamera.CFrame.Rotation * moveDirection).Unit * FLY_SPEED
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end
end)

uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == FLY_TOGGLE_KEY then
        if isFlying then
            stopFly()
        else
            startFly()
        end
    end
    if input.KeyCode == SPEED_TOGGLE_KEY then
        toggleSpeed()
    end
end)


local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    if isFast then
        humanoid.WalkSpeed = FAST_SPEED
    else
        humanoid.WalkSpeed = NORMAL_SPEED
    end
    
    humanoid.Died:Connect(function()
        if isFlying then
            stopFly()
        end
    end)
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)
