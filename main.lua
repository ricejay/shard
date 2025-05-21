repeat task.wait() until game:IsLoaded()

if game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") and not game:GetService("Players").LocalPlayer.PlayerGui.Intro_SCREEN:FindFirstChild("Frame").Loaded.Value == 2500 then
    return
end

loadstring(readfile("modules/eventShopModifier.lua"))()

task.wait(5)

local OrionLib = loadstring(game:HttpGet("https://twix.cyou/Orion.txt", true))()
local Window = OrionLib:MakeWindow({
    Name = "shard", 
    TestMode = false, 
    SaveConfig = true, 
    ConfigFolder = "shard_configs"
})
