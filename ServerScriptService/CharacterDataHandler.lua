-- @ScriptType: Script
-- @ScriptType: Script
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local playerDataStore = DataStoreService:GetDataStore("JoJoCampaignData_V1")

local custFolder = ReplicatedStorage:FindFirstChild("Customization")
if not custFolder then
	custFolder = Instance.new("Folder")
	custFolder.Name = "Customization"
	custFolder.Parent = ReplicatedStorage

	local folders = {"Outfits", "Accessories", "Eyes", "Eyebrows", "Nose", "Mouth"}
	for _, fName in ipairs(folders) do
		local f = Instance.new("Folder")
		f.Name = fName
		f.Parent = custFolder
	end

	local defaultShirt = Instance.new("Shirt")
	defaultShirt.Name = "Default"
	defaultShirt.ShirtTemplate = "rbxassetid://125195176"
	defaultShirt.Parent = custFolder.Outfits

	local defaultPants = Instance.new("Pants")
	defaultPants.Name = "Default"
	defaultPants.PantsTemplate = "rbxassetid://125195172"
	defaultPants.Parent = custFolder.Outfits
end

local DEFAULT_SHIRT_TEMPLATE = "rbxassetid://125195176"
local DEFAULT_PANTS_TEMPLATE = "rbxassetid://125195172"
local PEACH_SKIN_COLOR = Color3.fromRGB(225, 176, 135)
local BLACK_HAIR_COLOR = Color3.new(0, 0, 0)

local updateHairEvent = ReplicatedStorage:FindFirstChild("UpdateHairEvent")
if not updateHairEvent then
	updateHairEvent = Instance.new("RemoteEvent")
	updateHairEvent.Name = "UpdateHairEvent"
	updateHairEvent.Parent = ReplicatedStorage
end

local PlayerDataEvents = ReplicatedStorage:FindFirstChild("PlayerDataEvents")
if not PlayerDataEvents then
	PlayerDataEvents = Instance.new("Folder")
	PlayerDataEvents.Name = "PlayerDataEvents"
	PlayerDataEvents.Parent = ReplicatedStorage
	Instance.new("RemoteEvent", PlayerDataEvents).Name = "SyncPlayerData"
	Instance.new("RemoteFunction", PlayerDataEvents).Name = "RequestPlayerData"
end

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
	while not isDataLoaded[player.UserId] do task.wait(0.1) end
	return sessionData[player.UserId]
end

local function parseColor(str, defaultColor)
	if not str then return defaultColor end
	local r, g, b = str:match("(%d+),(%d+),(%d+)")
	if r and g and b then
		return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
	end
	return defaultColor
end

local function applyAvatar(player, character, pData)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	local skinColor = parseColor(pData.SkinColor, PEACH_SKIN_COLOR)
	local hairColor = parseColor(pData.HairColor, BLACK_HAIR_COLOR)

	local description = Instance.new("HumanoidDescription")
	description.Face = 0
	description.GraphicTShirt = 0
	description.HeadColor = skinColor
	description.LeftArmColor = skinColor
	description.RightArmColor = skinColor
	description.LeftLegColor = skinColor
	description.RightLegColor = skinColor
	description.TorsoColor = skinColor
	description.HairAccessory = pData.Hair or ""

	pcall(function()
		humanoid:ApplyDescription(description)
	end)

	local shirt = character:FindFirstChildWhichIsA("Shirt")
	if not shirt then
		shirt = Instance.new("Shirt")
		shirt.Parent = character
	end
	shirt.ShirtTemplate = pData.ShirtTemplate or DEFAULT_SHIRT_TEMPLATE

	local pants = character:FindFirstChildWhichIsA("Pants")
	if not pants then
		pants = Instance.new("Pants")
		pants.Parent = character
	end
	pants.PantsTemplate = pData.PantsTemplate or DEFAULT_PANTS_TEMPLATE

	local head = character:FindFirstChild("Head")
	if head then
		local headMesh = head:FindFirstChildOfClass("SpecialMesh")
		if not headMesh then
			headMesh = Instance.new("SpecialMesh")
			headMesh.MeshType = Enum.MeshType.Head
			headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
			headMesh.Parent = head
		end

		for _, v in ipairs(head:GetChildren()) do
			if v:IsA("Decal") and v.Name ~= "face" then v:Destroy() end
		end
		local features = {"Eyebrows", "Eyes", "Nose", "Mouth"}
		for _, fName in ipairs(features) do
			if pData[fName] then
				local fFolder = custFolder:FindFirstChild(fName)
				if fFolder then
					local decalProto = fFolder:FindFirstChild(pData[fName])
					if decalProto and decalProto:IsA("Decal") then
						local cl = decalProto:Clone()
						cl.Parent = head
					end
				end
			end
		end
	end

	local bodyColors = character:FindFirstChildWhichIsA("BodyColors")
	if not bodyColors then
		bodyColors = Instance.new("BodyColors")
		bodyColors.Parent = character
	end
	bodyColors.HeadColor3 = skinColor
	bodyColors.LeftArmColor3 = skinColor
	bodyColors.RightArmColor3 = skinColor
	bodyColors.LeftLegColor3 = skinColor
	bodyColors.RightLegColor3 = skinColor
	bodyColors.TorsoColor3 = skinColor

	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Color = skinColor
		end
	end

	for _, acc in ipairs(character:GetChildren()) do
		if acc:IsA("Accessory") and not acc:GetAttribute("IsCustom") then
			local handle = acc:FindFirstChild("Handle")
			if handle then
				local hairAttachment = handle:FindFirstChild("HairAttachment")
				if hairAttachment then
					for _, obj in ipairs(handle:GetChildren()) do
						if obj:IsA("SurfaceAppearance") then obj:Destroy() end
					end
					if handle:IsA("MeshPart") then
						handle.TextureID = ""
						handle.Color = hairColor
						handle.UsePartColor = true 
					else
						local mesh = handle:FindFirstChildOfClass("SpecialMesh")
						if mesh then mesh.TextureId = "" end
						handle.Color = hairColor
					end
				end
			end
		end
	end

	for _, acc in ipairs(character:GetChildren()) do
		if acc:IsA("Accessory") and acc:GetAttribute("IsCustom") then
			acc:Destroy()
		end
	end

	if pData.Accessory then
		local accFolder = custFolder:FindFirstChild("Accessories")
		if accFolder then
			local accProto = accFolder:FindFirstChild(pData.Accessory)
			if accProto and accProto:IsA("Accessory") then
				local cl = accProto:Clone()
				cl:SetAttribute("IsCustom", true)
				humanoid:AddAccessory(cl)
			end
		end
	end
end

local function onAppearanceLoaded(player, character)
	while not isDataLoaded[player.UserId] do task.wait(0.1) end
	local pData = sessionData[player.UserId]
	if pData then applyAvatar(player, character, pData) end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAppearanceLoaded:Connect(function(character)
		task.spawn(onAppearanceLoaded, player, character)
	end)

	local data
	pcall(function() data = playerDataStore:GetAsync(tostring(player.UserId)) end)

	if data then
		sessionData[player.UserId] = data
	else
		sessionData[player.UserId] = {
			Hair = nil,
			OriginalHair = nil,
			ShirtTemplate = DEFAULT_SHIRT_TEMPLATE,
			PantsTemplate = DEFAULT_PANTS_TEMPLATE,
			Accessory = nil,
			Eyebrows = nil,
			Eyes = nil,
			Nose = nil,
			Mouth = nil,
			SkinColor = "225,176,135",
			HairColor = "0,0,0",
			Cash = 0,
			ClaimedAchievements = {}
		}
	end

	-- Enforce defaults
	sessionData[player.UserId].Cash = sessionData[player.UserId].Cash or 0
	sessionData[player.UserId].ClaimedAchievements = sessionData[player.UserId].ClaimedAchievements or {}
	sessionData[player.UserId].ShirtTemplate = sessionData[player.UserId].ShirtTemplate or DEFAULT_SHIRT_TEMPLATE
	sessionData[player.UserId].PantsTemplate = sessionData[player.UserId].PantsTemplate or DEFAULT_PANTS_TEMPLATE
	sessionData[player.UserId].SkinColor = sessionData[player.UserId].SkinColor or "225,176,135"
	sessionData[player.UserId].HairColor = sessionData[player.UserId].HairColor or "0,0,0"

	-- Fetch Original Hair from API
	local realHair = ""
	local s, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(player.UserId) end)
	if s and desc then
		realHair = desc.HairAccessory
		if realHair == "" then
			for _, acc in ipairs(desc:GetAccessories(true)) do
				if acc.AccessoryType == Enum.AccessoryType.Hair then
					realHair = realHair .. (realHair == "" and "" or ",") .. tostring(acc.AssetId)
				end
			end
		end
	end

	sessionData[player.UserId].OriginalHair = sessionData[player.UserId].OriginalHair or realHair

	if not sessionData[player.UserId].Hair then
		sessionData[player.UserId].Hair = sessionData[player.UserId].OriginalHair
	end

	isDataLoaded[player.UserId] = true
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		task.spawn(onAppearanceLoaded, player, player.Character)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if sessionData[player.UserId] then
		pcall(function() playerDataStore:SetAsync(tostring(player.UserId), sessionData[player.UserId]) end)
		sessionData[player.UserId] = nil
	end
	isDataLoaded[player.UserId] = nil
end)

updateHairEvent.OnServerEvent:Connect(function(player, action, payload)
	local pData = sessionData[player.UserId]
	if not pData then return end

	if action == "CustomHair" then
		pData.Hair = tostring(payload)
	elseif action == "SkinColor" or action == "HairColor" then
		pData[action] = tostring(payload)
	elseif action == "Outfit" then
		pData.ShirtTemplate = payload.ShirtTemplate
		pData.PantsTemplate = payload.PantsTemplate
	elseif action == "Accessory" then
		if payload == "None" then
			pData.Accessory = nil
		else
			pData.Accessory = tostring(payload)
		end
	elseif action == "DefaultHair" then
		pData.Hair = pData.OriginalHair or ""
	elseif action == "Eyebrows" or action == "Eyes" or action == "Nose" or action == "Mouth" then
		pData[action] = tostring(payload)
	end

	if player.Character then
		applyAvatar(player, player.Character, pData)
	end
end)