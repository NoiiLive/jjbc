-- @ScriptType: Script
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")

local playerDataStore = DataStoreService:GetDataStore("JoJoCampaignData_V1")

local DEFAULT_SHIRT_ID = "rbxassetid://0"
local DEFAULT_PANTS_ID = "rbxassetid://0"
local PEACH_SKIN_COLOR = BrickColor.new("Light peach")
local BLACK_HAIR_COLOR = Color3.new(0, 0, 0)

local updateHairEvent = ReplicatedStorage:FindFirstChild("UpdateHairEvent")
if not updateHairEvent then
	updateHairEvent = Instance.new("RemoteEvent")
	updateHairEvent.Name = "UpdateHairEvent"
	updateHairEvent.Parent = ReplicatedStorage
end

local sessionData = {}

Players.PlayerAdded:Connect(function(player)
	local data
	local success, err = pcall(function()
		data = playerDataStore:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		sessionData[player.UserId] = data
	else
		sessionData[player.UserId] = {HairIDs = {}}
	end

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if humanoid then
			humanoid.RigType = Enum.HumanoidRigType.R6
		end

		local hasCustomHair = false
		if sessionData[player.UserId] and sessionData[player.UserId].HairIDs and #sessionData[player.UserId].HairIDs > 0 then
			hasCustomHair = true
		end

		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("CharacterMesh") then
				child:Destroy()
			elseif child:IsA("Accessory") then
				local handle = child:FindFirstChild("Handle")
				local isHair = false

				if handle then
					local attachment = handle:FindFirstChildOfClass("Attachment")
					if attachment and attachment.Name == "HairAttachment" then
						isHair = true
					end
				end

				if isHair then
					if hasCustomHair then
						child:Destroy()
					else
						if handle:IsA("MeshPart") then
							handle.TextureID = ""
							handle.Color = BLACK_HAIR_COLOR
						else
							local mesh = handle:FindFirstChildOfClass("SpecialMesh")
							if mesh then
								mesh.TextureId = ""
							end
							handle.Color = BLACK_HAIR_COLOR
						end
					end
				else
					child:Destroy()
				end
			end
		end

		if hasCustomHair then
			for _, id in ipairs(sessionData[player.UserId].HairIDs) do
				if id ~= "" and tonumber(id) then
					local s, model = pcall(function()
						return InsertService:LoadAsset(tonumber(id))
					end)
					if s and model then
						local accessory = model:FindFirstChildOfClass("Accessory")
						if accessory then
							accessory.Parent = character
						end
						model:Destroy()
					end
				end
			end
		end

		local head = character:FindFirstChild("Head")
		if head then
			local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
			if face then
				face:Destroy()
			end
		end

		local bodyColors = character:FindFirstChildOfClass("BodyColors")
		if bodyColors then
			bodyColors.HeadColor = PEACH_SKIN_COLOR
			bodyColors.LeftArmColor = PEACH_SKIN_COLOR
			bodyColors.RightArmColor = PEACH_SKIN_COLOR
			bodyColors.LeftLegColor = PEACH_SKIN_COLOR
			bodyColors.RightLegColor = PEACH_SKIN_COLOR
			bodyColors.TorsoColor = PEACH_SKIN_COLOR
		else
			for _, part in ipairs(character:GetChildren()) do
				if part:IsA("BasePart") then
					part.BrickColor = PEACH_SKIN_COLOR
				end
			end
		end

		local defaultShirt = Instance.new("Shirt")
		defaultShirt.ShirtTemplate = DEFAULT_SHIRT_ID
		defaultShirt.Parent = character

		local defaultPants = Instance.new("Pants")
		defaultPants.PantsTemplate = DEFAULT_PANTS_ID
		defaultPants.Parent = character
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if sessionData[player.UserId] then
		pcall(function()
			playerDataStore:SetAsync(tostring(player.UserId), sessionData[player.UserId])
		end)
		sessionData[player.UserId] = nil
	end
end)

updateHairEvent.OnServerEvent:Connect(function(player, hairIds)
	if type(hairIds) == "table" then
		if sessionData[player.UserId] then
			sessionData[player.UserId].HairIDs = hairIds
			if player.Character then
				player:LoadCharacter()
			end
		end
	end
end)