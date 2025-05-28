repeat task.wait() until game:IsLoaded()

-- services
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local virtualUser = game:GetService("VirtualUser")
local runService = game:GetService("RunService")

local player = players.LocalPlayer
local placeId = game.PlaceId
local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name

-- requires
local seedData = require(replicatedStorage.Data.SeedData)
local bytenetRemotes = require(replicatedStorage.Modules.Remotes)

-- game models
local farms = workspace:WaitForChild("Farm")
local mutations = replicatedStorage:WaitForChild("Mutation_FX")

-- libraries
local asssetLib = local assetLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ricejay/shard/refs/heads/main/modules/assets/icons.lua"))()
