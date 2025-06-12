local player = game:GetService("Players").LocalPlayer
local character = player.Character

if character then
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = 1
        end
    end
end