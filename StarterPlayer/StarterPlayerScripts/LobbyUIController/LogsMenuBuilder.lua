-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local LogsMenuBuilder = {}

function LogsMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
	local logsMenuBG, logsContainer, logsList = UIUtils.createStandardPopup("Logs", screenGui, bottomNavContainer)
	UIUtils.addListLayout(logsList, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	UIUtils.addPadding(logsList, 10)

	local logBox = Instance.new("Frame")
	logBox.Size = UDim2.new(1, 0, 0, 100)
	logBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	UIUtils.addCorner(logBox, 6)

	local lTitle = Instance.new("TextLabel")
	lTitle.Size = UDim2.new(0.9, 0, 0.3, 0)
	lTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
	lTitle.BackgroundTransparency = 1
	lTitle.Text = "Update v1.0.0"
	lTitle.TextColor3 = Color3.fromRGB(218, 165, 32)
	lTitle.Font = Enum.Font.Oswald
	lTitle.TextScaled = true
	lTitle.TextXAlignment = Enum.TextXAlignment.Left
	lTitle.Parent = logBox

	local lDesc = Instance.new("TextLabel")
	lDesc.Size = UDim2.new(0.9, 0, 0.55, 0)
	lDesc.Position = UDim2.new(0.05, 0, 0.4, 0)
	lDesc.BackgroundTransparency = 1
	lDesc.Text = "- Official Release of JoJo's Bizarre Campaign!\n- Welcome to the game."
	lDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
	lDesc.Font = Enum.Font.Gotham
	lDesc.TextScaled = true
	lDesc.TextXAlignment = Enum.TextXAlignment.Left
	lDesc.TextYAlignment = Enum.TextYAlignment.Top
	lDesc.Parent = logBox

	logBox.Parent = logsList

	return logsMenuBG
end

return LogsMenuBuilder