-- Generated with Sigma Spy Github: https://github.com/depthso/Sigma-Spy
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local RIFT_IS_DETECTED1 = workspace.demond_boy97["Chicken Zombie [3.86 KG] [Age 20]"]

-- Remote
local SellPet_RE = ReplicatedStorage.GameEvents.SellPet_RE -- RemoteEvent 

SellPet_RE:FireServer(
    RIFT_IS_DETECTED1
)


-- Generated with Sigma Spy Github: https://github.com/depthso/Sigma-Spy
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote
local ShecklesClient = ReplicatedStorage.GameEvents.ShecklesClient -- RemoteEvent 

-- This data was received from the server
firesignal(ShecklesClient.OnClientEvent, 
    "Cash Register"
)
