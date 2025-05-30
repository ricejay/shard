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
local assetLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ricejay/shard/refs/heads/main/modules/assets/icons.lua"))()
local fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local saveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local interfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local window = fluent:CreateWindow({
    Title = "shard.null",
    SubTitle = "by yvor",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local tabs = {
    mainTab = window:AddTab({ Title = "Main Tab", Icon = "" }),
    debug = window:AddTab({Title = "Debug", Icon = ""}),
    settingsTab = window:AddTab({ Title = "Settings", Icon = "settings" })
}

local options = fluent.Options

local selectedPlants = {}
local selectedMutations = {}
local selectedVariant = {}
local autoCollect = false

local lastCollect = 0
local collectCooldown = 0.2

local function pushAntiAfk()
    player.Idled:Connect(function(duration)
        virtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        virtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        print("[shard]: "..player.Name.." idled for "..duration)
    end)
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
        "Normal"
    }
    for _, mutation in ipairs(mutations:GetChildren()) do
        if mutation.Name ~= "Unused" then 
            table.insert(mutationsTable, mutation.Name)
        end
    end
    table.sort(mutationsTable)
    return mutationsTable
end

-- ui elements
task.spawn(function()
    
    pushAntiAfk()

    local plantsSelected = tabs.mainTab:AddDropdown("plantsSelected", {
        Title = "Select Plant to Collect",
        Values = getSeedNames(),
        Multi = true,
        Default = {},
        Callback = function(selected)
            selectedPlants = selected
        end
    })

    local mutationsSelected = tabs.mainTab:AddDropdown("mutationsSelected", {
        Title = "Select Mutation to Collect",
        Values = getMutationNames(),
        Multi = true,
        Default = {},
        Callback = function(selected)
            selectedMutations = selected
        end
    })

    local variantsSelected = tabs.mainTab:AddDropdown("variantsSelected", {
        Title = "Select Variant to Collect",
        Values = {"Gold", "Rainbow"},
        Multi = true,
        Default = {},
        Callback = function(selected)
            selectedVariant = selected
        end
    })

    local autoCollect = tabs.mainTab:AddToggle("autoCollect", {
        Title = "Auto Collect", 
        Default = false,
        Callback = function(bool)
            autoCollect = bool
        end
    })

    tabs.mainTab:AddButton({
        Title = "Print all fruit with variant (new)",
        Description = "Print all fruit with selected variant",
        Callback = function()
            local plantsFolder = getGarden():FindFirstChild("Important"):FindFirstChild("Plants_Physical")

            for _a, plant in pairs(plantsFolder:GetChildren()) do
                for plantName, _b in pairs(selectedPlants) do
                    if plant.Name == plantName then
                        local fruitFolder = plant:FindFirstChild("Fruits")

                        if fruitFolder then
                            for _c, fruitModel in pairs(fruitFolder:GetChildren()) do
                                if fruitModel:IsA("Model") then
                                    local variant = fruitModel:FindFirstChild("Variant")
                                    if variant and selectedVariant and next(selectedVariant) then
                                        for variantName, _d in pairs(selectedVariant) do
                                            if variant.Value == variantName then
                                                print(fruitModel.Name.." ✅ matches variant: "..variantName.."\nUUID: "..tostring(fruitModel:GetAttribute("UUID")))
                                            else
                                                print(fruitModel.Name.." ❌ does NOT match variant: "..variantName.."\nUUID: "..tostring(fruitModel:GetAttribute("UUID")))
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            local variant = plant:FindFirstChild("Variant")
                            if variant and selectedVariant and next(selectedVariant) then
                                for variantName, _e in pairs(selectedVariant) do
                                    if variant.Value == variantName then
                                        print(plant.Name.." ✅ matches variant: "..variantName.."\nUUID: "..tostring(plant:GetAttribute("UUID")))
                                    else
                                        print(plant.Name.." ❌ does NOT match variant: "..variantName.."\nUUID: "..tostring(plant:GetAttribute("UUID")))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    })

    tabs.mainTab:AddButton({
        Title = "Print all fruit with mutations",
        Description = "Print all fruit with selected mutations",
        Callback = function()
            local plantsFolder = getGarden():FindFirstChild("Important"):FindFirstChild("Plants_Physical")

            for _a, plant in pairs(plantsFolder:GetChildren()) do
                for plantName, _b in pairs(selectedPlants) do
                    if plant.Name == plantName then
                        local fruitFolder = plant:FindFirstChild("Fruits")

                        if fruitFolder then
                            for _c, fruitModel in pairs(fruitFolder:GetChildren()) do
                                if fruitModel:IsA("Model") then
                                    if selectedMutations and next(selectedMutations) then
                                        for mutationName, _d in pairs(selectedMutations) do
                                            if fruitModel:GetAttribute(mutationName) == true then
                                                print(fruitModel.Name.." ✅ matches mutation: "..mutationName.."\nUUID: "..tostring(fruitModel:GetAttribute("UUID")))
                                            else
                                                print(fruitModel.Name.." ❌ does NOT match mutation: "..mutationName.."\nUUID: "..tostring(fruitModel:GetAttribute("UUID")))
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            if selectedMutations and next(selectedMutations) then
                                for mutationName, _d in pairs(selectedMutations) do
                                    if plant:GetAttribute(mutationName) == true then
                                        print(plant.Name.." ✅ matches mutation: "..mutationName.."\nUUID: "..tostring(plant:GetAttribute("UUID")))
                                    else
                                        print(plant.Name.." ❌ does NOT match mutation: "..mutationName.."\nUUID: "..tostring(plant:GetAttribute("UUID")))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    })

    tabs.debug:AddButton({
        Title = "Print Selected", 
        Description = "Prints selected Plants",
        Callback = function()
            if selectedPlants ~= nil or selectedPlants ~= {} then
                for i ,v in pairs(selectedPlants) do
                    print("[selected]: "..i)
                end
            end
        end
    })

    tabs.debug:AddButton({
        Title = "Print Selected", 
        Description = "Prints selected Mutations",
        Callback = function()
            if selectedMutations ~= nil or selectedMutations ~= {} then
                for i ,v in pairs(selectedMutations) do
                    print("[selected]: "..i)
                end
            end
        end
    })

    tabs.debug:AddButton({
        Title = "Print Selected", 
        Description = "Prints selected Variant",
        Callback = function()
            if selectedVariant ~= nil or selectedVariant ~= {} then
                for i ,v in pairs(selectedVariant) do
                    print("[selected]: "..i)
                end
            end
        end
    })

    tabs.debug:AddButton({
        Title = "Collect Selected", 
        Description = "Collect Selected w/o mutations",
        Callback = function()
            local plantsFolder = getGarden():FindFirstChild("Important"):FindFirstChild("Plants_Physical")
            for _, plant in pairs(plantsFolder:GetChildren()) do
                for plantName, bool in pairs(selectedPlants) do
                    if plant.Name == plantName then
                        local fruitFolder = plant:FindFirstChild("Fruits")
                        local fruitItself = fruitFolder and fruitFolder:FindFirstChildOfClass("Model")

                        if fruitItself then
                            bytenetRemotes.Crops.Collect.send({fruitItself})
                        else
                            bytenetRemotes.Crops.Collect.send({plant})
                        end
                        return
                    end
                end
            end
        end
    })

    tabs.debug:AddButton({
        Title = "Collect Selected", 
        Description = "Collect Selected w variant",
        Callback = function()
            local plantsFolder = getGarden():FindFirstChild("Important"):FindFirstChild("Plants_Physical")
            for _, plant in pairs(plantsFolder:GetChildren()) do
                for plantName, bool in pairs(selectedPlants) do
                    if plant.Name == plantName then
                        local fruitFolder = plant:FindFirstChild("Fruits")
                        local fruitItself = fruitFolder and fruitFolder:FindFirstChildOfClass("Model")

                        local function matchesVariant(target)
                            if selectedVariant and next(selectedVariant) then
                                local variantValue = target:FindFirstChild("Variant")
                                if variantValue then
                                    for variantName, _ in pairs(selectedVariant) do
                                        if variantValue.Value == variantName then
                                            return true
                                        end
                                    end
                                end
                                return false
                            else
                                return true -- No variant filter = allow any
                            end
                        end

                        if fruitItself and matchesVariant(fruitItself) then
                            bytenetRemotes.Crops.Collect.send({fruitItself})
                            return
                        elseif matchesVariant(plant) then
                            bytenetRemotes.Crops.Collect.send({plant})
                            return
                        else
                            print("Could not find variant match for:", plantName)
                        end
                    end
                end
            end
        end
    })


    tabs.debug:AddButton({
        Title = "Collect Selected", 
        Description = "Collect Selected w mutations",
        Callback = function()
            local plantsFolder = getGarden():FindFirstChild("Important"):FindFirstChild("Plants_Physical")
            for _, plant in pairs(plantsFolder:GetChildren()) do
                for plantName, bool in pairs(selectedPlants) do
                    if plant.Name == plantName then
                        local fruitFolder = plant:FindFirstChild("Fruits")
                        local fruitItself = fruitFolder and fruitFolder:FindFirstChildOfClass("Model")

                        if fruitItself then
                            if selectedMutations ~= nil or selectedMutations ~= {} then
                                for mutationName, bool2 in pairs(selectedMutations) do
                                    if fruitItself:GetAttribute(mutationName) == true then
                                        bytenetRemotes.Crops.Collect.send({fruitItself})
                                    else
                                        print("cannot find fruit with ["..mutationName.."] mutation")
                                    end
                                end
                            else
                                bytenetRemotes.Crops.Collect.send({fruitItself})
                            end
                        else
                            if selectedMutations ~= nil or selectedMutations ~= {} then
                                for mutationName, bool2 in pairs(selectedMutations) do
                                    if fruitItself:GetAttribute(mutationName) == true then
                                        bytenetRemotes.Crops.Collect.send({plant})
                                    else
                                        print("cannot find fruit with ["..mutationName.."] mutation")
                                    end
                                end
                            else
                                bytenetRemotes.Crops.Collect.send({plant})
                            end
                        end
                        return
                    end
                end
            end
        end
    })
end)

saveManager:SetLibrary(fluent)
interfaceManager:SetLibrary(fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
saveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
saveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
interfaceManager:SetFolder("shardnull")
saveManager:SetFolder("shardnull/gag")

interfaceManager:BuildInterfaceSection(tabs.settingsTab)
saveManager:BuildConfigSection(tabs.settingsTab)

window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
saveManager:LoadAutoloadConfig()