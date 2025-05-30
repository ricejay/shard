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
    Transparency = false,
    MinimizeKey = Enum.KeyCode.LeftControl
})

local tabs = {
    mainTab = window:AddTab({ Title = "Exploit", Icon = "" }),
    settingsTab = window:AddTab({ Title = "Settings", Icon = "settings" })
}

local options = fluent.Options

getgenv().dupeSheckles = false
getgenv().dupeMultiplier = 1

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")
local runService = game:GetService("RunService")

local sellPet_RE = replicatedStorage:WaitForChild("GameEvents").SellPet_RE

function pushJoinDiscord()
    setclipboard("https://discord.gg/m5bf9EdD8U")
    fluent:Notify({
        Title = "Join our Discord!",
        Content = "Link copied to clipboard. Paste it in your browser to join!",
        Duration = 5
    })
end

local function pushAntiAfk()
    localPlayer.Idled:Connect(function(duration)
        virtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        virtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end

task.spawn(function()

    pushAntiAfk()

    window:Dialog({
        Title = "shard.null",
        Content = "Join Our Discord!",
        Buttons = {
            { 
                Title = "Copy Link",
                Callback = function()
                    pushJoinDiscord()
                end 
            }
        }
    })

    tabs.mainTab:AddParagraph({
        Title = "How To Use:",
        Content = "[1] Join a private server with your friend/alt.\n[2] Make your friend/alt hold a pet.\n[3] Start the dupe."
    })
    tabs.mainTab:AddParagraph({
        Title = "Warning:",
        Content = "[-] Do not use on main account.\n[-] You might get wiped or banned."
    })

    local dupeShecks = tabs.mainTab:AddToggle("dupeShecks", {
        Title = "Dupe Sheckles", 
        Default = false,
        Callback = function(bool)
            getgenv().dupeSheckles = bool
        end
    })

    local dupeMultiplier = tabs.mainTab:AddSlider("dupeMultiplier", {
        Title = "Dupe Multiplier",,
        Description = "Dupe Multiplier for more sheckles (laggy)",
        Default = 1,
        Min = 1,
        Max = 50,
        Rounding = 1,
        Callback = function(value)
            getgenv().dupeMultiplier = value
        end
    })

    runService.RenderStepped:Connect(function()

        if getgenv().dupeSheckles then
            for _, player in ipairs(players:GetPlayers()) do
                if player ~= localPlayer then
                    local function handlePet(pet)
                        if pet:GetAttribute("ItemType") == "Pet" then
                            local rift = Workspace[player.Name]:FindFirstChild(pet.Name)
                            if rift then
                                for i = 1, getgenv().dupeMultiplier do
                                    sellPet_RE:FireServer(rift)
                                end
                            end
                        end
                    end

                    local function monitorCharacter(character)
                        for _, child in ipairs(character:GetChildren()) do
                            handlePet(child)
                        end
                        character.ChildAdded:Connect(handlePet)
                    end

                    if player.Character then
                        monitorCharacter(player.Character)
                    end
                    player.CharacterAdded:Connect(monitorCharacter)
                end
            end
        end
    end)

end)

saveManager:SetLibrary(fluent)
interfaceManager:SetLibrary(fluent)

saveManager:IgnoreThemeSettings()

saveManager:SetIgnoreIndexes({})

interfaceManager:SetFolder("shardnull")
saveManager:SetFolder("shardnull/gag")

interfaceManager:BuildInterfaceSection(tabs.settingsTab)
saveManager:BuildConfigSection(tabs.settingsTab)

window:SelectTab(1)

saveManager:LoadAutoloadConfig()