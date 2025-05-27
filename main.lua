repeat task.wait() until game:IsLoaded()

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local virtualUser = game:GetService("VirtualUser")
local runService = game:GetService("RunService")

local player = players.LocalPlayer
local placeId = game.PlaceId
local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name

local seedData = require(replicatedStorage.Data.SeedData)

local assetLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ricejay/shard/refs/heads/main/modules/assets.lua"))()
local orionLib = loadstring(game:HttpGetAsync("https://twix.cyou/Orion.txt", true))()
local window = orionLib:MakeWindow({
    Name = "shard", 
    TestMode = false, 
    SaveConfig = true, 
    Icon = assetLib["shardIcon"],
    ConfigFolder = "shard_configs"
})

local mainTab = window:MakeTab({
    Name = "Main",
	Icon = "",
	TestersOnly = false
})

local function getSeedNames()
    local seedsTable = {}
    for _, seed in next, seedData do
        local fixedName = string.gsub(seed.SeedName, " Seed$", "")
        table.insert(seedsTable, fixedName)
    end
    table.sort(seedsTable)
    return seedsTable
end

task.spawn(function()
    
    mainTab:AddDropdown({
        Name = "Select Seed",
        Default = "",
        Options = getSeedNames(),
        Callback = function(selected)
            print(selected)
        end
    })

    runService.RenderStepped:Connect(function()
        player.Idled:Connect(function()
            print("[shard-debug]: user idled")
            virtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            virtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end)

end)