-- @ScriptType: ModuleScript
local PopupBuilder = {}

function PopupBuilder.build(screenGui, UIUtils, bottomNavContainer)
	local popups = {}

	local partyMenuBG, partyContainer, partyList = UIUtils.createStandardPopup("Party", screenGui, bottomNavContainer)
	popups["Party"] = partyMenuBG
	partyList.Size = UDim2.new(0.95, 0, 0.55, 0)

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

	local goalsMenuBG = UIUtils.createStandardPopup("Goals", screenGui, bottomNavContainer)
	popups["Goals"] = goalsMenuBG

	local shopMenuBG = UIUtils.createStandardPopup("Shop", screenGui, bottomNavContainer)
	popups["Shop"] = shopMenuBG

	local logsMenuBG = UIUtils.createStandardPopup("Logs", screenGui, bottomNavContainer)
	popups["Logs"] = logsMenuBG

	return popups
end

return PopupBuilder