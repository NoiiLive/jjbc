-- @ScriptType: Script
-- @ScriptType: Script
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local playerDataStore = DataStoreService:GetDataStore("JoJoCampaignData_V1")

local DEFAULT_SHIRT_ID = 0
local DEFAULT_PANTS_ID = 0
local PEACH_SKIN_COLOR = Color3.fromRGB(225, 176, 135)
local BLACK_HAIR_COLOR = Color3.new(0, 0, 0)

local updateHairEvent = ReplicatedStorage:FindFirstChild("UpdateHairEvent")
if not updateHairEvent then
	updateHairEvent = Instance.new("RemoteEvent")
	updateHairEvent.Name = "UpdateHairEvent"
	updateHairEvent.Parent = ReplicatedStorage
end

-- Create events for syncing data to the client
local PlayerDataEvents = ReplicatedStorage:FindFirstChild("PlayerDataEvents")
if not PlayerDataEvents then
	PlayerDataEvents = Instance.new("Folder")
	PlayerDataEvents.Name = "PlayerDataEvents"
	PlayerDataEvents.Parent = ReplicatedStorage

	Instance.new("RemoteEvent", PlayerDataEvents).Name = "SyncPlayerData"
	Instance.new("RemoteFunction", PlayerDataEvents).Name = "RequestPlayerData"
end

-- Create events for Server-to-Server data manipulation
local ServerDataEvents = ServerStorage:FindFirstChild("ServerDataEvents")
if not ServerDataEvents then
	ServerDataEvents = Instance.new("Folder")
	ServerDataEvents.Name = "ServerDataEvents"
	ServerDataEvents.Parent = ServerStorage

	Instance.new("BindableFunction", ServerDataEvents).Name = "GetPlayerData"
	Instance.new("BindableEvent", ServerDataEvents).Name = "SetPlayerData"
end

local sessionData = {}
local isDataLoaded = {}

ServerDataEvents.GetPlayerData.OnInvoke = function(player)
	return sessionData[player.UserId]
end

ServerDataEvents.SetPlayerData.Event:Connect(function(player, key, value)
	if sessionData[player.UserId] then
		sessionData[player.UserId][key] = value
		PlayerDataEvents.SyncPlayerData:FireClient(player, sessionData[player.UserId])
	end
end)

PlayerDataEvents.RequestPlayerData.OnServerInvoke = function(player)
	while not isDataLoaded[player.UserId] do
		task.wait(0.1)
	end
	return sessionData[player.UserId]
end

local function applyAvatar(player, character, hairData)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	local description = Instance.new("HumanoidDescription")

	description.Shirt = DEFAULT_SHIRT_ID
	description.Pants = DEFAULT_PANTS_ID
	description.Face = 0
	description.GraphicTShirt = 0

	description.HeadColor = PEACH_SKIN_COLOR
	description.LeftArmColor = PEACH_SKIN_COLOR
	description.RightArmColor = PEACH_SKIN_COLOR
	description.LeftLegColor = PEACH_SKIN_COLOR
	description.RightLegColor = PEACH_SKIN_COLOR
	description.TorsoColor = PEACH_SKIN_COLOR

	description.HairAccessory = hairData or ""

	pcall(function()
		humanoid:ApplyDescription(description)
	end)

	local head = character:FindFirstChild("Head")
	if head then
		local headMesh = head:FindFirstChildOfClass("SpecialMesh")
		if not headMesh then
			headMesh = Instance.new("SpecialMesh")
			headMesh.MeshType = Enum.MeshType.Head
			headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
			headMesh.Parent = head
		end
	end

	local bodyColors = character:FindFirstChildWhichIsA("BodyColors")
	if not bodyColors then
		bodyColors = Instance.new("BodyColors")
		bodyColors.Parent = character
	end

	bodyColors.HeadColor3 = PEACH_SKIN_COLOR
	bodyColors.LeftArmColor3 = PEACH_SKIN_COLOR
	bodyColors.RightArmColor3 = PEACH_SKIN_COLOR
	bodyColors.LeftLegColor3 = PEACH_SKIN_COLOR
	bodyColors.RightLegColor3 = PEACH_SKIN_COLOR
	bodyColors.TorsoColor3 = PEACH_SKIN_COLOR

	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Color = PEACH_SKIN_COLOR
		end
	end

	for _, acc in ipairs(character:GetChildren()) do
		if acc:IsA("Accessory") then
			local handle = acc:FindFirstChild("Handle")
			if handle then
				local hairAttachment = handle:FindFirstChild("HairAttachment")
				if hairAttachment then
					for _, obj in ipairs(handle:GetChildren()) do
						if obj:IsA("SurfaceAppearance") then
							obj:Destroy()
						end
					end

					if handle:IsA("MeshPart") then
						handle.TextureID = ""
						handle.Color = BLACK_HAIR_COLOR
						handle.UsePartColor = true 
					else
						local mesh = handle:FindFirstChildOfClass("SpecialMesh")
						if mesh then
							mesh.TextureId = ""
						end
						handle.Color = BLACK_HAIR_COLOR
					end
				end
			end
		end
	end
end

local function onAppearanceLoaded(player, character)
	while not isDataLoaded[player.UserId] do
		task.wait(0.1)
	end

	local pData = sessionData[player.UserId]
	if pData then
		applyAvatar(player, character, pData.Hair)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAppearanceLoaded:Connect(function(character)
		task.spawn(onAppearanceLoaded, player, character)
	end)

	local data
	local success, err = pcall(function()
		data = playerDataStore:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		sessionData[player.UserId] = data
	else
		sessionData[player.UserId] = {
			Hair = nil,
			Cash = 0,
			ClaimedAchievements = {}
		}
	end

	-- Ensure defaults exist for older data saves
	sessionData[player.UserId].Cash = sessionData[player.UserId].Cash or 0
	sessionData[player.UserId].ClaimedAchievements = sessionData[player.UserId].ClaimedAchievements or {}

	if not sessionData[player.UserId].Hair then
		local s, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(player.UserId) end)
		if s and desc then
			local hairs = desc.HairAccessory
			if hairs == "" then
				for _, acc in ipairs(desc:GetAccessories(true)) do
					if acc.AccessoryType == Enum.AccessoryType.Hair then
						hairs = hairs .. (hairs == "" and "" or ",") .. tostring(acc.AssetId)
					end
				end
			end
			sessionData[player.UserId].Hair = hairs
		else
			sessionData[player.UserId].Hair = ""
		end
	end

	isDataLoaded[player.UserId] = true

	if player.Character and player.Character:FindFirstChild("Humanoid") then
		task.spawn(onAppearanceLoaded, player, player.Character)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if sessionData[player.UserId] then
		pcall(function()
			playerDataStore:SetAsync(tostring(player.UserId), sessionData[player.UserId])
		end)
		sessionData[player.UserId] = nil
	end
	isDataLoaded[player.UserId] = nil
end)

updateHairEvent.OnServerEvent:Connect(function(player, action, payload)
	local pData = sessionData[player.UserId]
	if not pData then return end

	if action == "Custom" then
		pData.Hair = tostring(payload)
	elseif action == "Default" then
		local success, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(player.UserId) end)
		if success and desc then
			local hairs = desc.HairAccessory
			if hairs == "" then
				for _, acc in ipairs(desc:GetAccessories(true)) do
					if acc.AccessoryType == Enum.AccessoryType.Hair then
						hairs = hairs .. (hairs == "" and "" or ",") .. tostring(acc.AssetId)
					end
				end
			end
			pData.Hair = hairs
		end
	end

	if player.Character then
		applyAvatar(player, player.Character, pData.Hair)
	end
end)