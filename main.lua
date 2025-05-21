repeat task.wait() until game:IsLoaded()

if game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") and not game:GetService("Players").LocalPlayer.PlayerGui.Intro_SCREEN:FindFirstChild("Frame").Loaded.Value == 2500 then
    return
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/ricejay/shard/refs/heads/main/modules/eventShopModifier.lua"))()

task.wait(5)

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local player = players["LocalPlayer"]

local orionLib = loadstring(game:HttpGet("https://twix.cyou/Orion.txt", true))()
local window = orionLib:MakeWindow({
    Name = "shard", 
    TestMode = false, 
    SaveConfig = true, 
    ConfigFolder = "shard_configs"
})

