-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyEvents = ReplicatedStorage:WaitForChild("EconomyEvents")
local PlayerDataEvents = ReplicatedStorage:WaitForChild("PlayerDataEvents")

local GoalsMenuBuilder = {}

function GoalsMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
	local goalsMenuBG, goalsContainer, goalsList = UIUtils.createStandardPopup("Goals", screenGui, bottomNavContainer)
	UIUtils.addListLayout(goalsList, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	UIUtils.addPadding(goalsList, 10)

	local goalBox = Instance.new("Frame")
	goalBox.Size = UDim2.new(1, 0, 0, 60)
	goalBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	UIUtils.addCorner(goalBox, 6)

	local gTitle = Instance.new("TextLabel")
	gTitle.Size = UDim2.new(0.6, 0, 0.5, 0)
	gTitle.Position = UDim2.new(0.05, 0, 0.1, 0)
	gTitle.BackgroundTransparency = 1
	gTitle.Text = "JoJo's Bizarre Campaign"
	gTitle.TextColor3 = Color3.fromRGB(218, 165, 32)
	gTitle.Font = Enum.Font.Oswald
	gTitle.TextScaled = true
	gTitle.TextXAlignment = Enum.TextXAlignment.Left
	gTitle.Parent = goalBox

	local gDesc = Instance.new("TextLabel")
	gDesc.Size = UDim2.new(0.6, 0, 0.3, 0)
	gDesc.Position = UDim2.new(0.05, 0, 0.6, 0)
	gDesc.BackgroundTransparency = 1
	gDesc.Text = "Thanks for joining the game!"
	gDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
	gDesc.Font = Enum.Font.Gotham
	gDesc.TextScaled = true
	gDesc.TextXAlignment = Enum.TextXAlignment.Left
	gDesc.Parent = goalBox

	local claimBtn = UIUtils.createButton("ClaimBtn", "Loading...", goalBox)
	claimBtn.Size = UDim2.new(0.25, 0, 0.6, 0)
	claimBtn.Position = UDim2.new(0.7, 0, 0.2, 0)
	claimBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

	task.spawn(function()
		local pData = PlayerDataEvents.RequestPlayerData:InvokeServer()
		local isClaimed = pData.ClaimedAchievements and pData.ClaimedAchievements["Welcome"]

		claimBtn.Text = isClaimed and "Claimed!" or "Claim"
		claimBtn.BackgroundColor3 = isClaimed and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 120, 30)
	end)

	claimBtn.MouseButton1Click:Connect(function()
		if claimBtn.Text == "Claim" then
			EconomyEvents.ClaimAchievement:FireServer("Welcome")
		end
	end)

	PlayerDataEvents.SyncPlayerData.OnClientEvent:Connect(function(newData)
		if newData.ClaimedAchievements and newData.ClaimedAchievements["Welcome"] then
			claimBtn.Text = "Claimed!"
			claimBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		end
	end)

	goalBox.Parent = goalsList

	return goalsMenuBG
end

return GoalsMenuBuilder