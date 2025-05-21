repeat task.wait() until game:IsLoaded()

if game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") and not game:GetService("Players").LocalPlayer.PlayerGui.Intro_SCREEN:FindFirstChild("Frame").Loaded.Value == 2500 then
    return
end

loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ricejay/shard/refs/heads/main/modules/eventShopModifier.lua"))()

task.wait(5)

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")

local player = players.LocalPlayer
local placeId = game.PlaceId

local eventShopModule = require(replicatedStorage.Data.EventShopData)

local assetLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ricejay/shard/refs/heads/main/modules/assets.lua"))()
local orionLib = loadstring(game:HttpGetAsync("https://twix.cyou/Orion.txt", true))()
local window = orionLib:MakeWindow({
    Name = "shard", 
    TestMode = false, 
    SaveConfig = true, 
    Icon = assetLib["shardIcon"],
    ConfigFolder = "shard_configs"
})

local tabTest = window:MakeTab({
    Name = "Tab 1",
	Icon = "",
	TestersOnly = false
})

local function checkServerVersion()
    local buggedItems = {
        "Candy Blossom",
        "Chocolate Sprinkler",
        "Easter Egg",
        "Candy Sunflower",
        "Red Lollipop",
        "Chocolate Carrot"
    }

    local isOld = false

    for _, itemName in ipairs(buggedItems) do
        local itemData = eventShopModule[itemName]
        if itemData and itemData["StockChance"] and itemData["StockChance"] > 0 then
            isOld = true
            break
        else
            isOld = false
            break
        end
    end

    return isOld
end

tabTest:AddButton({
    Name = "Check Server Version",
    Callback = function()
        local isOld = checkServerVersion()
        if isOld then
            orionLib:MakeNotification({
                Name = "Shard",
                Content = "Server is Old ✅\n\nServer Version: "..game.PlaceVersion,
                Image = assetLib["shardIcon"],
                Time = 5
            })
        else
            orionLib:MakeNotification({
                Name = "Shard",
                Content = "Server is not Old ❎\n\nServer Version: "..game.PlaceVersion,
                Image = assetLib["shardIcon"],
                Time = 5
            })
        end
    end
})