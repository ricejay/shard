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

local dupeSheckles = false

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
        Title = "shard.nul",
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
        Content = "[-] Do not use on main accoun.\n[-] You might get wiped or banned."
    })

    local dupeShecks = tabs.mainTab:AddToggle("dupeShecks", {
        Title = "Dupe Sheckles", 
        Default = false,
        Callback = function(bool)
            dupeSheckles = bool
        end
    })

    runService.RenderStepped:Connect(function()

        if dupeSheckles then
            for _, player in ipairs(players:GetPlayers()) do
                if player ~= localPlayer then
                    local function processCharacter(character)
                        local function handlePet(pet)
                            if pet:GetAttribute("ItemType") == "Pet" then
                                local rift = Workspace[player.Name]:FindFirstChild(pet.Name)
                                if rift then
                                    sellPet_RE:FireServer(rift)
                                end
                            end
                        end

                        for _, child in ipairs(character:GetChildren()) do
                            handlePet(child)
                        end

                        character.ChildAdded:Connect(function(itemAdded)
                            handlePet(itemAdded)
                        end)
                    end

                    if player.Character then
                        processCharacter(player.Character)
                    end
                    player.CharacterAdded:Connect(processCharacter)
                end
            end
        end
    end)

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