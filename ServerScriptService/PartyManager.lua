-- @ScriptType: Script
-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local GAME_PLACE_ID = 80744294773461

local PartyEvents = ReplicatedStorage:FindFirstChild("PartyEvents")
if not PartyEvents then
	PartyEvents = Instance.new("Folder")
	PartyEvents.Name = "PartyEvents"
	PartyEvents.Parent = ReplicatedStorage

	local eventsToCreate = {
		"CreateParty",
		"JoinParty",
		"LeaveParty",
		"DisbandParty",
		"StartGame",
		"UpdatePartyData",
		"RefreshPartyList",
		"RequestPartyList",
		"ToggleModifier"
	}

	for _, eventName in ipairs(eventsToCreate) do
		local event = Instance.new("RemoteEvent")
		event.Name = eventName
		event.Parent = PartyEvents
	end
end

local parties = {}

local function getPartySummary()
	local list = {}
	for hostId, party in pairs(parties) do
		table.insert(list, {
			HostId = hostId,
			HostName = party.HostName,
			CurrentSize = #party.Members,
			MaxSize = party.MaxSize,
			Difficulty = party.Difficulty,
			FriendsOnly = party.FriendsOnly
		})
	end
	return list
end

local function broadcastPartyList()
	PartyEvents.RefreshPartyList:FireAllClients(getPartySummary())
end

local function broadcastPartyUpdate(hostId)
	local party = parties[hostId]
	if not party then return end

	for _, member in ipairs(party.Members) do
		local player = Players:GetPlayerByUserId(member.UserId)
		if player then
			PartyEvents.UpdatePartyData:FireClient(player, party)
		end
	end
end

PartyEvents.RequestPartyList.OnServerEvent:Connect(function(player)
	PartyEvents.RefreshPartyList:FireClient(player, getPartySummary())
end)

PartyEvents.CreateParty.OnServerEvent:Connect(function(player, size, friendsOnly, difficulty)
	for hostId, party in pairs(parties) do
		for _, member in ipairs(party.Members) do
			if member.UserId == player.UserId then
				return
			end
		end
	end

	parties[player.UserId] = {
		Host = player.UserId,
		HostName = player.Name,
		MaxSize = size or 5,
		FriendsOnly = friendsOnly or false,
		Difficulty = difficulty or "Normal",
		Modifiers = {},
		Members = {
			{UserId = player.UserId, Name = player.Name, IsHost = true}
		}
	}

	broadcastPartyUpdate(player.UserId)
	broadcastPartyList()
end)

PartyEvents.JoinParty.OnServerEvent:Connect(function(player, hostId)
	local party = parties[hostId]
	if not party then return end

	if #party.Members >= party.MaxSize then return end

	if party.FriendsOnly then
		local hostPlayer = Players:GetPlayerByUserId(hostId)
		if hostPlayer and not player:IsFriendsWith(hostPlayer.UserId) then
			return
		end
	end

	for _, p in pairs(parties) do
		for _, m in ipairs(p.Members) do
			if m.UserId == player.UserId then return end
		end
	end

	table.insert(party.Members, {UserId = player.UserId, Name = player.Name, IsHost = false})
	broadcastPartyUpdate(hostId)
	broadcastPartyList()
end)

PartyEvents.LeaveParty.OnServerEvent:Connect(function(player)
	for hostId, party in pairs(parties) do
		for i, member in ipairs(party.Members) do
			if member.UserId == player.UserId then
				if member.IsHost then
					for _, m in ipairs(party.Members) do
						local p = Players:GetPlayerByUserId(m.UserId)
						if p then
							PartyEvents.UpdatePartyData:FireClient(p, nil)
						end
					end
					parties[hostId] = nil
				else
					table.remove(party.Members, i)
					broadcastPartyUpdate(hostId)
					PartyEvents.UpdatePartyData:FireClient(player, nil)
				end
				broadcastPartyList()
				return
			end
		end
	end
end)

PartyEvents.DisbandParty.OnServerEvent:Connect(function(player)
	local party = parties[player.UserId]
	if party and party.Host == player.UserId then
		for _, member in ipairs(party.Members) do
			local p = Players:GetPlayerByUserId(member.UserId)
			if p then
				PartyEvents.UpdatePartyData:FireClient(p, nil)
			end
		end
		parties[player.UserId] = nil
		broadcastPartyList()
	end
end)

PartyEvents.StartGame.OnServerEvent:Connect(function(player)
	local party = parties[player.UserId]
	if party and party.Host == player.UserId then
		local playersToTeleport = {}
		for _, member in ipairs(party.Members) do
			local p = Players:GetPlayerByUserId(member.UserId)
			if p then
				table.insert(playersToTeleport, p)
			end
		end

		local success, err = pcall(function()
			local tsCode = TeleportService:ReserveServer(GAME_PLACE_ID)
			local teleportOptions = Instance.new("TeleportOptions")
			teleportOptions.ReservedServerAccessCode = tsCode

			teleportOptions:SetTeleportData({
				PartyData = party
			})

			TeleportService:TeleportAsync(GAME_PLACE_ID, playersToTeleport, teleportOptions)
		end)

		if not success then
			warn("Failed to teleport party: ", err)
		end
	end
end)

PartyEvents.ToggleModifier.OnServerEvent:Connect(function(player, modName, state)
	local party = parties[player.UserId]
	if party and party.Host == player.UserId then
		party.Modifiers[modName] = state
		broadcastPartyUpdate(player.UserId)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local changed = false
	for hostId, party in pairs(parties) do
		if hostId == player.UserId then
			for _, member in ipairs(party.Members) do
				local p = Players:GetPlayerByUserId(member.UserId)
				if p and p ~= player then
					PartyEvents.UpdatePartyData:FireClient(p, nil)
				end
			end
			parties[hostId] = nil
			changed = true
		else
			for i, member in ipairs(party.Members) do
				if member.UserId == player.UserId then
					table.remove(party.Members, i)
					broadcastPartyUpdate(hostId)
					changed = true
					break
				end
			end
		end
	end

	if changed then
		broadcastPartyList()
	end
end)