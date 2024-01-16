local mod = RegisterMod("Gun Game", 1)
local GUN_GAME_ID = Isaac.GetItemIdByName("Gun Game")
local GUN_GAME_CHALLENGE_ID = Isaac.GetChallengeIdByName("Gun Game")

function mod:GunGameChallenge()
    if Isaac.GetChallenge() == GUN_GAME_CHALLENGE_ID then
        local player = Isaac.GetPlayer(0)
        player:AddCollectible(GUN_GAME_ID)
    end
end

function mod:GunGame()
    local player = Isaac.GetPlayer(0)
    local inventory = {}

    if player:HasCollectible(GUN_GAME_ID) then
        local numCollectibles = player:GetCollectibleCount()
        if numCollectibles >= 1 then
            for i = 1, CollectibleType.NUM_COLLECTIBLES do
                local config = Isaac.GetItemConfig():GetCollectible(i)

                if player:HasCollectible(i) and
                i ~= GUN_GAME_ID and
                config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST and
                config.Type ~= ItemType.ITEM_ACTIVE then
                    local collectibleCount = player:GetCollectibleNum(i, true)
                    for j = 1, collectibleCount do
                        player:RemoveCollectible(i)
                        table.insert(inventory, i)
                    end
                end
            end
            
            for _, id in ipairs(inventory) do
                local item = Isaac.GetItemConfig():GetCollectible(GetNextPossibleId(id))
                player:AddCollectible(item.ID)
            end
        end
    end
end

function GetNextPossibleId(id)
    id = id + 1      
    if Isaac.GetItemConfig():GetCollectible(id) == nil then
        id = id + 1
        if (Isaac.GetItemConfig():GetCollectible(id) == nil and Isaac.GetItemConfig():GetCollectible(id+1) == nil) then
            id = 1
        end
    end

    while (Isaac.GetItemConfig():GetCollectible(id) ~= nil and BlockedItem(id)) do
        id = id + 1
        if (Isaac.GetItemConfig():GetCollectible(id) == nil and Isaac.GetItemConfig():GetCollectible(id+1) == nil) then
            id = 1
        elseif (Isaac.GetItemConfig():GetCollectible(id) == nil and Isaac.GetItemConfig():GetCollectible(id+1) ~= nil) then
            id = id + 1
        end
    end
    return id
end

function BlockedItem(id)
    local config = Isaac.GetItemConfig():GetCollectible(id)
    return IsKeyItem(config) == true or
        IsActiveItem(config) == true or
        IsTmTrainer(id) == true or
        IsMissingNo(id) == true or
        config.Hidden == true or
        id == GUN_GAME_ID
end

function IsKeyItem(config)
    return config.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST
end

function IsActiveItem(config)
    return config.Type == ItemType.ITEM_ACTIVE
end

function IsMissingNo(id)
    return id == 258
end

function IsTmTrainer(id)
    return id == 721
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.GunGame)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.GunGameChallenge)