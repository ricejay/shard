local eventShopModule = require(game:GetService("ReplicatedStorage").Data.EventShopData)

for _, item in next, eventShopModule do
    if item["DisplayInShop"] == false then
        item["DisplayInShop"] = true
        print(item["SeedName"].. ": loaded!")
    else
        warn(item["SeedName"].. " cannot find!")
    end
end