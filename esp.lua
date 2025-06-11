local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local espContainer = Instance.new("ScreenGui")
espContainer.Name = "ESP_Container"
espContainer.ResetOnSpawn = false
espContainer.Parent = localPlayer:WaitForChild("PlayerGui")

local playerVisuals = {}

local VISIBLE_COLOR = Color3.fromRGB(0, 255, 127)
local OCCLUDED_COLOR = Color3.fromRGB(255, 80, 80)
local HEALTH_LOW_COLOR = Color3.fromRGB(255, 100, 100)
local HEALTH_HIGH_COLOR = Color3.fromRGB(100, 255, 100)
local TRACER_THICKNESS = 1.5

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function removeVisuals(player)
	if playerVisuals[player] then
		local visuals = playerVisuals[player]
		if visuals.mainBillboard then visuals.mainBillboard:Destroy() end
		if visuals.tracer then visuals.tracer:Destroy() end
		if visuals.headDotBillboard then visuals.headDotBillboard:Destroy() end
		playerVisuals[player] = nil
	end
end

local function updateVisuals(player)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")

	if not (humanoid and hrp and head and humanoid.Health > 0) then
		removeVisuals(player)
		return
	end

	local visuals = playerVisuals[player]
	if not visuals then
		visuals = {}
		playerVisuals[player] = visuals
		
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "MainBillboard"
		billboard.AlwaysOnTop = true
		billboard.LightInfluence = 0
		billboard.Size = UDim2.fromOffset(100, 100)
		billboard.Adornee = hrp
		visuals.mainBillboard = billboard

		local box = Instance.new("BoxHandleAdornment")
		box.Name = "Box"
		box.AlwaysOnTop = true
		box.ZIndex = 2
		box.Size = character:GetExtentsSize()
		box.Adornee = hrp
		box.Transparency = 0.6
		box.Parent = billboard
		visuals.box = box

		local healthBarBg = Instance.new("Frame")
		healthBarBg.Name = "HealthBarBg"
		healthBarBg.Size = UDim2.new(0.1, 0, 1, 0)
		healthBarBg.Position = UDim2.new(-0.6, 0, 0, 0)
		healthBarBg.BackgroundColor3 = Color3.new(0,0,0)
		healthBarBg.BackgroundTransparency = 0.5
		healthBarBg.BorderSizePixel = 0
		healthBarBg.Parent = box
		
		local healthBar = Instance.new("Frame")
		healthBar.Name = "HealthBar"
		healthBar.Size = UDim2.new(1, 0, 1, 0)
		healthBar.AnchorPoint = Vector2.new(0, 1)
		healthBar.Position = UDim2.new(0, 0, 1, 0)
		healthBar.BackgroundColor3 = HEALTH_HIGH_COLOR
		healthBar.BorderSizePixel = 0
		healthBar.Parent = healthBarBg
		visuals.healthBar = healthBar
		
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Name = "InfoLabel"
		infoLabel.Size = UDim2.new(3, 0, 0.5, 0)
		infoLabel.Position = UDim2.new(0.5, 0, -0.6, 0)
		infoLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		infoLabel.Font = Enum.Font.SourceSans
		infoLabel.TextSize = 14
		infoLabel.TextColor3 = Color3.new(1,1,1)
		infoLabel.TextStrokeTransparency = 0
		infoLabel.BackgroundTransparency = 1
		infoLabel.Parent = box
		visuals.infoLabel = infoLabel
		
		local headDotBillboard = Instance.new("BillboardGui")
		headDotBillboard.Name = "HeadDotBillboard"
		headDotBillboard.AlwaysOnTop = true
		headDotBillboard.LightInfluence = 0
		headDotBillboard.Size = UDim2.fromOffset(10, 10)
		headDotBillboard.Adornee = head
		visuals.headDotBillboard = headDotBillboard

		local headDot = Instance.new("Frame")
		headDot.Name = "HeadDot"
		headDot.Size = UDim2.fromScale(1,1)
		headDot.BackgroundColor3 = VISIBLE_COLOR
		headDot.BorderSizePixel = 0
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = headDot
		headDot.Parent = headDotBillboard
		visuals.headDot = headDot

		local tracer = Instance.new("Frame")
		tracer.Name = "Tracer"
		tracer.AnchorPoint = Vector2.new(0.5, 0.5)
		tracer.BackgroundColor3 = VISIBLE_COLOR
		tracer.BorderSizePixel = 0
		tracer.Parent = espContainer
		visuals.tracer = tracer
		
		billboard.Parent = espContainer
		headDotBillboard.Parent = espContainer
	end

	local origin = camera.CFrame.Position
	local direction = (hrp.Position - origin)
	
	raycastParams.FilterDescendantsInstances = {localPlayer.Character, espContainer}
	local ray = workspace:Raycast(origin, direction, raycastParams)
	
	local isVisible = not ray or ray.Instance:IsDescendantOf(character)
	local currentColor = isVisible and VISIBLE_COLOR or OCCLUDED_COLOR
	
	visuals.box.Color3 = currentColor
	visuals.box.Size = character:GetExtentsSize() + Vector3.new(0.2, 0.2, 0.2)
	visuals.infoLabel.TextColor3 = currentColor
	visuals.headDot.BackgroundColor3 = currentColor
	visuals.tracer.BackgroundColor3 = currentColor
	
	local healthFraction = humanoid.Health / humanoid.MaxHealth
	visuals.healthBar.Size = UDim2.fromScale(1, healthFraction)
	visuals.healthBar.BackgroundColor3 = HEALTH_HIGH_COLOR:Lerp(HEALTH_LOW_COLOR, 1 - healthFraction)
	
	visuals.infoLabel.Text = string.format("%s [%.0fm]", player.Name, direction.Magnitude)
	
	local screenPos, onScreen = camera:WorldToScreenPoint(hrp.Position)
	if onScreen then
		visuals.tracer.Visible = true
		local startPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
		local endPos = Vector2.new(screenPos.X, screenPos.Y)
		local magnitude = (startPos - endPos).Magnitude
		local center = startPos:Lerp(endPos, 0.5)
		local angle = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))

		visuals.tracer.Position = UDim2.fromOffset(center.X, center.Y)
		visuals.tracer.Size = UDim2.fromOffset(magnitude, TRACER_THICKNESS)
		visuals.tracer.Rotation = angle
	else
		visuals.tracer.Visible = false
	end
end

local function onRenderStep()
	local playersInFrame = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			playersInFrame[player] = true
			updateVisuals(player)
		end
	end

	for player in pairs(playerVisuals) do
		if not playersInFrame[player] then
			removeVisuals(player)
		end
	end
end

RunService.RenderStepped:Connect(onRenderStep)
Players.PlayerRemoving:Connect(removeVisuals)