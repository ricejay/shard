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
local byteNetRemotes = require(replicatedStorage.Modules.Remotes)

-- game modles
local farms = workspace:WaitForChild("Farm")
local mutations = replicatedStorage:WaitForChild("Mutation_FX")

-- libraries
local assetLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ricejay/shard/refs/heads/main/modules/assets/icons.lua"))()
local rayField = loadstring(game:HttpGet('https://raw.githubusercontent.com/ricejay/shard/refs/heads/main/modules/assets/rayfield.lua'))()
local window = rayField:CreateWindow({
   Name = "shard",
   Icon = 116005003944281,
   LoadingTitle = "shard",
   LoadingSubtitle = "by ricevor",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
})

local mainTab = window:CreateTab("Main", "")
local farmModule = mainTab:CreateSection("Farm Module")

local function pushAntiAfk()
    print("[shard-debug]: user idled")
    virtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    virtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end

local function getGarden()
    for _, farm in pairs(farms:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == player.Name then
            return farm
        end
    end
end

local function getSeedNames()
    local seedsTable = {
        "None"
    }
    for _, seed in next, seedData do
        local fixedName = string.gsub(seed.SeedName, " Seed$", "")
        table.insert(seedsTable, fixedName)
    end
    table.sort(seedsTable)
    return seedsTable
end

local function getMutationNames()
    local mutationsTable = {
        "None"
    }
    for _, mutation in ipairs(mutations:GetChildren()) do
        if mutation.Name ~= "Unused" then 
            table.insert(mutationsTable, mutation.Name)
        end
    end
    table.sort(mutationsTable)
    return mutationsTable
end

task.spawn(function()

    player.Idled:Connect(function()
        pushAntiAfk()
    end)

    -- global env / locals
    getgenv().selectedPlant = ""
    getgenv().selectedMutation = ""
    getgenv().autoCollect = false

    local lastCollect = 0
    local collectCooldown = 0.2

    mainTab:CreateDropdown({
        Name = "Select Plant To Collect",
        Options = getSeedNames(),
        CurrentOption = "None",
        MultipleOptions = true,
        Callback = function(selected)
            getgenv().selectedPlant = selected
        end
    })

    mainTab:CreateDropdown({
        Name = "Select Mutations",
        Options = getMutationNames(),
        CurrentOption = "None",
        MultipleOptions = true,
        Callback = function(selected)
            getgenv().selectedMutation = selected
        end
    })

    mainTab:CreateToggle({
        Name = "Collect Fruit",
        CurrentValue = false,
        Callback = function(bool)
            getgenv().autoCollect = bool
        end
    })

    runService.RenderStepped:Connect(function()
        if tick() - lastCollect < collectCooldown then return end
        if getgenv().autoCollect and getgenv().selectedPlant ~= "None" then
            local plantsFolder = getGarden():FindFirstChild("Important"):FindFirstChild("Plants_Physical")

            for _, plant in pairs(plantsFolder:GetChildren()) do
                if plant.Name == getgenv().selectedPlant then
                    local fruitFolder = plant:FindFirstChild("Fruits")
                    local fruitItself = fruitFolder and fruitFolder:FindFirstChildOfClass("Model")

                    if fruitItself then
                        if getgenv().selectedMutation ~= "None" then
                            print("Checking plant:", plant.Name, " | Mutation:", fruitItself and fruitItself:GetAttribute(getgenv().selectedMutation))
                            if fruitItself:GetAttribute(getgenv().selectedMutation) == true then
                                byteNetRemotes.Crops.Collect.send({fruitItself})
                                lastCollect = tick()
                                break
                            end
                        else
                            byteNetRemotes.Crops.Collect.send({fruitItself})
                            lastCollect = tick()
                            break
                        end
                    else
                        if getgenv().selectedMutation ~= "None" then
                            print("Checking plant:", plant.Name, " | Mutation:", fruitItself and fruitItself:GetAttribute(getgenv().selectedMutation))
                            if plant:GetAttribute(getgenv().selectedMutation) == true then
                                byteNetRemotes.Crops.Collect.send({plant})
                                lastCollect = tick()
                                break
                            end
                        else
                            byteNetRemotes.Crops.Collect.send({plant})
                            lastCollect = tick()
                            break
                        end
                    end
                end
            end
        end
    end)

end)