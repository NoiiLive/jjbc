-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvents = ReplicatedStorage:WaitForChild("PartyEvents")

local PartyMenuBuilder = {}

local friendCache = {}
local function checkIsFriend(userId)
	if userId == Players.LocalPlayer.UserId then return true end
	if friendCache[userId] ~= nil then return friendCache[userId] end
	local success, isFriend = pcall(function()
		return Players.LocalPlayer:IsFriendsWith(userId)
	end)
	if success then
		friendCache[userId] = isFriend
		return isFriend
	end
	return false
end

function PartyMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
	local currentPartyHostId = 0

	local partyMenuBG, partyContainer, partyList = UIUtils.createStandardPopup("Party", screenGui, bottomNavContainer)
	partyList.Size = UDim2.new(0.95, 0, 0.55, 0)
	UIUtils.addListLayout(partyList, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	UIUtils.addPadding(partyList, 10)

	local partyBottomBar = Instance.new("Frame")
	partyBottomBar.Name = "PartyBottomBar"
	partyBottomBar.AnchorPoint = Vector2.new(0.5, 1)
	partyBottomBar.Size = UDim2.new(0.95, 0, 0.12, 0)
	partyBottomBar.Position = UDim2.new(0.5, 0, 0.82, 0)
	partyBottomBar.BackgroundTransparency = 1
	partyBottomBar.Parent = partyContainer

	local partySearch = Instance.new("TextBox")
	partySearch.Name = "SearchBar"
	partySearch.Size = UDim2.new(0.65, 0, 1, 0)
	partySearch.Text = ""
	partySearch.PlaceholderText = "Search username..."
	partySearch.Font = Enum.Font.Oswald
	partySearch.TextScaled = true
	partySearch.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	partySearch.TextColor3 = Color3.fromRGB(240, 240, 240)
	partySearch.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	local searchStroke = Instance.new("UIStroke")
	searchStroke.Color = Color3.fromRGB(218, 165, 32)
	searchStroke.Thickness = 1
	searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	searchStroke.Parent = partySearch
	UIUtils.addCorner(partySearch, 6)
	UIUtils.addPadding(partySearch, 10)
	partySearch.Parent = partyBottomBar

	local createPartyBtn = UIUtils.createButton("CreatePartyButton", "Create Party", partyBottomBar)
	createPartyBtn.Size = UDim2.new(0.3, 0, 1, 0)
	createPartyBtn.Position = UDim2.new(0.7, 0, 0, 0)

	local partyCreationFrame = Instance.new("Frame")
	partyCreationFrame.Name = "PartyCreationMenu"
	partyCreationFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
	partyCreationFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
	partyCreationFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	partyCreationFrame.Visible = false
	UIUtils.addCorner(partyCreationFrame, 8)
	local pcStroke = Instance.new("UIStroke")
	pcStroke.Color = Color3.fromRGB(218, 165, 32)
	pcStroke.Thickness = 2
	pcStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcStroke.Parent = partyCreationFrame
	partyCreationFrame.Parent = partyContainer

	local pcTitle = Instance.new("TextLabel")
	pcTitle.Name = "Title"
	pcTitle.Size = UDim2.new(1, 0, 0.15, 0)
	pcTitle.BackgroundTransparency = 1
	pcTitle.Text = "Create Party"
	pcTitle.Font = Enum.Font.Oswald
	pcTitle.TextScaled = true
	pcTitle.TextColor3 = Color3.fromRGB(218, 165, 32)
	pcTitle.Parent = partyCreationFrame

	local pcCloseBtn = UIUtils.createButton("CloseCreation", "X", partyCreationFrame)
	pcCloseBtn.Size = UDim2.new(0.1, 0, 0.1, 0)
	pcCloseBtn.Position = UDim2.new(0.9, 0, 0, 0)
	pcCloseBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
	pcCloseBtn.MouseButton1Click:Connect(function()
		partyCreationFrame.Visible = false
	end)

	createPartyBtn.MouseButton1Click:Connect(function()
		partyCreationFrame.Visible = true
	end)

	local sizeContainer = Instance.new("Frame")
	sizeContainer.Name = "SizeContainer"
	sizeContainer.Size = UDim2.new(0.8, 0, 0.15, 0)
	sizeContainer.Position = UDim2.new(0.1, 0, 0.2, 0)
	sizeContainer.BackgroundTransparency = 1
	sizeContainer.Parent = partyCreationFrame

	local sizeLabel = Instance.new("TextLabel")
	sizeLabel.Size = UDim2.new(0.5, 0, 1, 0)
	sizeLabel.BackgroundTransparency = 1
	sizeLabel.Text = "Party Size: 5"
	sizeLabel.Font = Enum.Font.Oswald
	sizeLabel.TextScaled = true
	sizeLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	sizeLabel.Parent = sizeContainer

	local downBtn = UIUtils.createButton("DownBtn", "<", sizeContainer)
	downBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
	downBtn.Position = UDim2.new(0.55, 0, 0.1, 0)

	local upBtn = UIUtils.createButton("UpBtn", ">", sizeContainer)
	upBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
	upBtn.Position = UDim2.new(0.75, 0, 0.1, 0)

	local currentSize = 5
	local function updateSize()
		sizeLabel.Text = "Party Size: " .. currentSize
	end

	downBtn.MouseButton1Click:Connect(function()
		currentSize = currentSize - 1
		if currentSize < 1 then currentSize = 5 end
		updateSize()
	end)

	upBtn.MouseButton1Click:Connect(function()
		currentSize = currentSize + 1
		if currentSize > 5 then currentSize = 1 end
		updateSize()
	end)

	local friendsContainer = Instance.new("Frame")
	friendsContainer.Name = "FriendsContainer"
	friendsContainer.Size = UDim2.new(0.8, 0, 0.15, 0)
	friendsContainer.Position = UDim2.new(0.1, 0, 0.4, 0)
	friendsContainer.BackgroundTransparency = 1
	friendsContainer.Parent = partyCreationFrame

	local friendsLabel = Instance.new("TextLabel")
	friendsLabel.Size = UDim2.new(0.5, 0, 1, 0)
	friendsLabel.BackgroundTransparency = 1
	friendsLabel.Text = "Friends Only"
	friendsLabel.Font = Enum.Font.Oswald
	friendsLabel.TextScaled = true
	friendsLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	friendsLabel.Parent = friendsContainer

	local friendsToggle = UIUtils.createButton("FriendsToggle", "OFF", friendsContainer)
	friendsToggle.Size = UDim2.new(0.3, 0, 0.8, 0)
	friendsToggle.Position = UDim2.new(0.6, 0, 0.1, 0)
	local isFriendsOnly = false

	friendsToggle.MouseButton1Click:Connect(function()
		isFriendsOnly = not isFriendsOnly
		friendsToggle.Text = isFriendsOnly and "ON" or "OFF"
		friendsToggle.BackgroundColor3 = isFriendsOnly and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(35, 35, 35)
	end)

	local diffContainer = Instance.new("Frame")
	diffContainer.Name = "DifficultyContainer"
	diffContainer.Size = UDim2.new(0.8, 0, 0.15, 0)
	diffContainer.Position = UDim2.new(0.1, 0, 0.6, 0)
	diffContainer.BackgroundTransparency = 1
	diffContainer.Parent = partyCreationFrame

	local diffLabel = Instance.new("TextLabel")
	diffLabel.Size = UDim2.new(0.5, 0, 1, 0)
	diffLabel.BackgroundTransparency = 1
	diffLabel.Text = "Difficulty: Normal"
	diffLabel.Font = Enum.Font.Oswald
	diffLabel.TextScaled = true
	diffLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	diffLabel.Parent = diffContainer

	local diffDown = UIUtils.createButton("DiffDown", "<", diffContainer)
	diffDown.Size = UDim2.new(0.15, 0, 0.8, 0)
	diffDown.Position = UDim2.new(0.55, 0, 0.1, 0)

	local diffUp = UIUtils.createButton("DiffUp", ">", diffContainer)
	diffUp.Size = UDim2.new(0.15, 0, 0.8, 0)
	diffUp.Position = UDim2.new(0.75, 0, 0.1, 0)

	local difficulties = {"Easy", "Normal", "Hard", "Nightmare"}
	local currentDiff = 2
	local function updateDiff()
		diffLabel.Text = "Difficulty: " .. difficulties[currentDiff]
	end

	diffDown.MouseButton1Click:Connect(function()
		currentDiff = currentDiff - 1
		if currentDiff < 1 then currentDiff = 4 end
		updateDiff()
	end)

	diffUp.MouseButton1Click:Connect(function()
		currentDiff = currentDiff + 1
		if currentDiff > 4 then currentDiff = 1 end
		updateDiff()
	end)

	local confirmCreate = UIUtils.createButton("ConfirmCreate", "Start Party", partyCreationFrame)
	confirmCreate.Size = UDim2.new(0.5, 0, 0.15, 0)
	confirmCreate.Position = UDim2.new(0.25, 0, 0.8, 0)
	confirmCreate.BackgroundColor3 = Color3.fromRGB(30, 120, 30)

	local partyWaitingFrame = Instance.new("Frame")
	partyWaitingFrame.Name = "PartyWaitingMenu"
	partyWaitingFrame.Size = UDim2.new(1, 0, 1, 0)
	partyWaitingFrame.BackgroundTransparency = 1
	partyWaitingFrame.Visible = false
	partyWaitingFrame.Parent = partyContainer

	local activeMembers = Instance.new("ScrollingFrame")
	activeMembers.Name = "ActiveMembers"
	activeMembers.Size = UDim2.new(0.45, 0, 0.6, 0)
	activeMembers.Position = UDim2.new(0.025, 0, 0.1, 0)
	activeMembers.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	activeMembers.ScrollBarImageColor3 = Color3.fromRGB(218, 165, 32)
	UIUtils.addCorner(activeMembers, 8)
	UIUtils.addListLayout(activeMembers, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	UIUtils.addPadding(activeMembers, 10)
	activeMembers.Parent = partyWaitingFrame

	local modifiersList = Instance.new("ScrollingFrame")
	modifiersList.Name = "ModifiersList"
	modifiersList.Size = UDim2.new(0.45, 0, 0.6, 0)
	modifiersList.Position = UDim2.new(0.525, 0, 0.1, 0)
	modifiersList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	modifiersList.ScrollBarImageColor3 = Color3.fromRGB(218, 165, 32)
	UIUtils.addCorner(modifiersList, 8)
	UIUtils.addListLayout(modifiersList, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	UIUtils.addPadding(modifiersList, 10)
	modifiersList.Parent = partyWaitingFrame

	local modExamples = {
		{Name = "Vampiric Foes", Desc = "Enemies heal for 50% of damage dealt. +20% EXP"},
		{Name = "Frailty", Desc = "Party max health is reduced by 25%. +15% Cash"},
		{Name = "Enraged", Desc = "Enemies deal 50% more damage. +30% EXP"},
		{Name = "Item Drought", Desc = "No item drops after combat encounters. +25% Cash"}
	}

	local dynamicModToggles = {}

	for _, mod in ipairs(modExamples) do
		local modSlot = Instance.new("Frame")
		modSlot.Name = "ModifierSlot"
		modSlot.Size = UDim2.new(1, 0, 0, 65)
		modSlot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		UIUtils.addCorner(modSlot, 6)

		local mTitle = Instance.new("TextLabel")
		mTitle.Size = UDim2.new(0.65, 0, 0.5, 0)
		mTitle.Position = UDim2.new(0.05, 0, 0.1, 0)
		mTitle.BackgroundTransparency = 1
		mTitle.Text = mod.Name
		mTitle.TextColor3 = Color3.fromRGB(218, 165, 32)
		mTitle.Font = Enum.Font.Oswald
		mTitle.TextScaled = true
		mTitle.TextXAlignment = Enum.TextXAlignment.Left
		mTitle.Parent = modSlot

		local mDesc = Instance.new("TextLabel")
		mDesc.Size = UDim2.new(0.6, 0, 0.45, 0)
		mDesc.Position = UDim2.new(0.05, 0, 0.55, 0)
		mDesc.BackgroundTransparency = 1
		mDesc.Text = mod.Desc
		mDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
		mDesc.Font = Enum.Font.Gotham
		mDesc.TextScaled = true
		mDesc.TextXAlignment = Enum.TextXAlignment.Left
		mDesc.Parent = modSlot

		local mToggle = UIUtils.createButton("ToggleBtn", "OFF", modSlot)
		mToggle.Size = UDim2.new(0.25, 0, 0.5, 0)
		mToggle.Position = UDim2.new(0.7, 0, 0.1, 0)
		dynamicModToggles[mod.Name] = mToggle

		mToggle.MouseButton1Click:Connect(function()
			if currentPartyHostId == Players.LocalPlayer.UserId then
				local currentState = mToggle.Text == "ON"
				PartyEvents.ToggleModifier:FireServer(mod.Name, not currentState)
			end
		end)

		modSlot.Parent = modifiersList
	end

	local disbandBtn = UIUtils.createButton("DisbandBtn", "Disband", partyWaitingFrame)
	disbandBtn.Size = UDim2.new(0.35, 0, 0.1, 0)
	disbandBtn.Position = UDim2.new(0.1, 0, 0.72, 0)
	disbandBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)

	local startWaitingBtn = UIUtils.createButton("StartGameBtn", "Start Game", partyWaitingFrame)
	startWaitingBtn.Size = UDim2.new(0.35, 0, 0.1, 0)
	startWaitingBtn.Position = UDim2.new(0.55, 0, 0.72, 0)
	startWaitingBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)

	confirmCreate.MouseButton1Click:Connect(function()
		PartyEvents.CreateParty:FireServer(currentSize, isFriendsOnly, difficulties[currentDiff])
	end)

	disbandBtn.MouseButton1Click:Connect(function()
		if disbandBtn.Text == "Disband" then
			PartyEvents.DisbandParty:FireServer()
		else
			PartyEvents.LeaveParty:FireServer()
		end
	end)

	startWaitingBtn.MouseButton1Click:Connect(function()
		PartyEvents.StartGame:FireServer()
	end)

	PartyEvents.UpdatePartyData.OnClientEvent:Connect(function(partyData)
		if partyData then
			currentPartyHostId = partyData.Host

			partyCreationFrame.Visible = false
			partyList.Visible = false
			partyBottomBar.Visible = false
			local titleNode = partyContainer:FindFirstChild("Title")
			if titleNode then titleNode.Text = "Party Lobby" end
			partyWaitingFrame.Visible = true

			for _, child in ipairs(activeMembers:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			for i = 1, partyData.MaxSize do
				local memberSlot = Instance.new("Frame")
				memberSlot.Name = "MemberSlot" .. i
				memberSlot.Size = UDim2.new(1, 0, 0, 50)
				memberSlot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				UIUtils.addCorner(memberSlot, 6)

				local mName = Instance.new("TextLabel")
				mName.Size = UDim2.new(0.9, 0, 1, 0)
				mName.Position = UDim2.new(0.05, 0, 0, 0)
				mName.BackgroundTransparency = 1

				local memberInfo = partyData.Members[i]
				if memberInfo then
					mName.Text = memberInfo.Name .. (memberInfo.IsHost and " (Host)" or "")
					mName.TextColor3 = memberInfo.IsHost and Color3.fromRGB(218, 165, 32) or Color3.fromRGB(240, 240, 240)
				else
					mName.Text = "Waiting for player..."
					mName.TextColor3 = Color3.fromRGB(150, 150, 150)
				end

				mName.Font = Enum.Font.Oswald
				mName.TextScaled = true
				mName.TextXAlignment = Enum.TextXAlignment.Left
				mName.Parent = memberSlot
				memberSlot.Parent = activeMembers
			end

			for modName, mToggle in pairs(dynamicModToggles) do
				local isOn = partyData.Modifiers[modName] or false
				mToggle.Text = isOn and "ON" or "OFF"
				mToggle.BackgroundColor3 = isOn and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(35, 35, 35)

				if currentPartyHostId ~= Players.LocalPlayer.UserId then
					mToggle.BackgroundTransparency = 0.5
					mToggle.TextTransparency = 0.5
				else
					mToggle.BackgroundTransparency = 0
					mToggle.TextTransparency = 0
				end
			end

			local isLocalHost = partyData.Host == Players.LocalPlayer.UserId
			if isLocalHost then
				disbandBtn.Text = "Disband"
				startWaitingBtn.Visible = true
			else
				disbandBtn.Text = "Leave"
				startWaitingBtn.Visible = false
			end
		else
			currentPartyHostId = 0
			partyWaitingFrame.Visible = false
			partyList.Visible = true
			partyBottomBar.Visible = true
			local titleNode = partyContainer:FindFirstChild("Title")
			if titleNode then titleNode.Text = "Party" end
		end
	end)

	PartyEvents.RefreshPartyList.OnClientEvent:Connect(function(partiesData)
		task.spawn(function()
			for _, pData in ipairs(partiesData) do
				local isFull = pData.CurrentSize >= pData.MaxSize
				local isFriend = checkIsFriend(pData.HostId)

				if isFull then
					pData.SortScore = 3
					pData.NameColor = Color3.fromRGB(200, 50, 50) 
				elseif pData.FriendsOnly then
					if isFriend then
						pData.SortScore = 1
						pData.NameColor = Color3.fromRGB(50, 200, 50) 
					else
						pData.SortScore = 3
						pData.NameColor = Color3.fromRGB(200, 50, 50) 
					end
				else
					pData.SortScore = 2
					pData.NameColor = Color3.fromRGB(240, 240, 240)
				end
			end

			table.sort(partiesData, function(a, b)
				if a.SortScore == b.SortScore then
					return a.HostName < b.HostName
				end
				return a.SortScore < b.SortScore
			end)

			for _, child in ipairs(partyList:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			for _, pData in ipairs(partiesData) do
				local pBox = Instance.new("Frame")
				pBox.Size = UDim2.new(1, 0, 0, 60)
				pBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				UIUtils.addCorner(pBox, 6)

				local pName = Instance.new("TextLabel")
				pName.Size = UDim2.new(0.5, 0, 0.5, 0)
				pName.Position = UDim2.new(0.05, 0, 0.1, 0)
				pName.BackgroundTransparency = 1
				pName.Text = pData.HostName .. "'s Party"
				pName.TextColor3 = pData.NameColor
				pName.Font = Enum.Font.Oswald
				pName.TextScaled = true
				pName.TextXAlignment = Enum.TextXAlignment.Left
				pName.Parent = pBox

				local pInfo = Instance.new("TextLabel")
				pInfo.Size = UDim2.new(0.5, 0, 0.3, 0)
				pInfo.Position = UDim2.new(0.05, 0, 0.6, 0)
				pInfo.BackgroundTransparency = 1
				pInfo.Text = "Size: " .. pData.CurrentSize .. "/" .. pData.MaxSize .. " | Diff: " .. pData.Difficulty
				pInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
				pInfo.Font = Enum.Font.Gotham
				pInfo.TextScaled = true
				pInfo.TextXAlignment = Enum.TextXAlignment.Left
				pInfo.Parent = pBox

				local pJoinBtn = UIUtils.createButton("JoinBtn", "Join", pBox)
				pJoinBtn.Size = UDim2.new(0.25, 0, 0.6, 0)
				pJoinBtn.Position = UDim2.new(0.7, 0, 0.2, 0)
				pJoinBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)

				if pData.SortScore == 3 then
					pJoinBtn.Visible = false
				end

				pJoinBtn.MouseButton1Click:Connect(function()
					PartyEvents.JoinParty:FireServer(pData.HostId)
				end)

				pBox.Parent = partyList
			end
		end)
	end)

	task.spawn(function()
		PartyEvents.RequestPartyList:FireServer()
	end)

	return partyMenuBG
end

return PartyMenuBuilder