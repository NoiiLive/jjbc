-- @ScriptType: Script
-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local EconomyEvents = ReplicatedStorage:FindFirstChild("EconomyEvents")
if not EconomyEvents then
	EconomyEvents = Instance.new("Folder")
	EconomyEvents.Name = "EconomyEvents"
	EconomyEvents.Parent = ReplicatedStorage

	local claimEvent = Instance.new("RemoteEvent")
	claimEvent.Name = "ClaimAchievement"
	claimEvent.Parent = EconomyEvents
end

local ServerDataEvents = ServerStorage:WaitForChild("ServerDataEvents")
local GetPlayerData = ServerDataEvents:WaitForChild("GetPlayerData")
local SetPlayerData = ServerDataEvents:WaitForChild("SetPlayerData")

EconomyEvents.ClaimAchievement.OnServerEvent:Connect(function(player, achievementId)
	local pData = GetPlayerData:Invoke(player)
	if not pData then return end

	if achievementId == "Welcome" then
		if not pData.ClaimedAchievements["Welcome"] then
			-- Clone the table so Roblox registers the state change properly
			local newAchievements = {}
			for k, v in pairs(pData.ClaimedAchievements) do newAchievements[k] = v end

			newAchievements["Welcome"] = true
			local newCash = (pData.Cash or 0) + 25

			SetPlayerData:Fire(player, "ClaimedAchievements", newAchievements)
			SetPlayerData:Fire(player, "Cash", newCash)

			print(player.Name .. " claimed the Welcome achievement! Awarding 25 Cash.")
		else
			warn(player.Name .. " attempted to claim the Welcome achievement again.")
		end
	end
end)

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	print(player.Name .. " successfully purchased Product ID: " .. receiptInfo.ProductId)
	-- Hook future product logic here

	return Enum.ProductPurchaseDecision.PurchaseGranted
end