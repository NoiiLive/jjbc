-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local updateHairEvent = ReplicatedStorage:WaitForChild("UpdateHairEvent")

local PlayerMenuBuilder = {}

function PlayerMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
	local playerMenu = Instance.new("Frame")
	playerMenu.Name = "PlayerMenu"
	playerMenu.Size = UDim2.new(1, 0, 1, 0)
	playerMenu.Position = UDim2.new(0, 0, 0, 0)
	playerMenu.BackgroundTransparency = 1 
	playerMenu.Visible = false
	playerMenu.Parent = screenGui

	local playerTopNav = Instance.new("Frame")
	playerTopNav.Name = "PlayerTopNav"
	playerTopNav.AnchorPoint = Vector2.new(0.5, 0)
	playerTopNav.Size = UDim2.new(0.6, 0, 0.08, 0)
	playerTopNav.Position = UDim2.new(0.5, 0, 0.02, 0)
	playerTopNav.BackgroundTransparency = 1 
	UIUtils.addListLayout(playerTopNav, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 15)
	UIUtils.addPadding(playerTopNav, 10)
	playerTopNav.Parent = playerMenu

	local pMenus = {"Customization", "Classes", "Perks"}
	local pMenuFrames = {}
	local pMenuButtons = {}

	for i, pMenu in ipairs(pMenus) do
		local btn = UIUtils.createButton(pMenu .. "Button", pMenu, playerTopNav)
		btn.Size = UDim2.new(0.3, 0, 1, 0)
		pMenuButtons[pMenu] = btn
	end

	local playerFinishBtn = UIUtils.createButton("FinishButton", "Finish", playerMenu)
	playerFinishBtn.AnchorPoint = Vector2.new(0.5, 1)
	playerFinishBtn.Size = UDim2.new(0.2, 0, 0.08, 0)
	playerFinishBtn.Position = UDim2.new(0.5, 0, 0.95, 0)
	playerFinishBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)

	local customizationMenu = Instance.new("Frame")
	customizationMenu.Name = "CustomizationMenu"
	customizationMenu.AnchorPoint = Vector2.new(0.5, 0.5)
	customizationMenu.Size = UDim2.new(0.9, 0, 0.7, 0)
	customizationMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
	customizationMenu.BackgroundTransparency = 1
	customizationMenu.Visible = true
	customizationMenu.Parent = playerMenu
	pMenuFrames["Customization"] = customizationMenu

	local custLeftSide = Instance.new("ScrollingFrame")
	custLeftSide.Name = "LeftSide"
	custLeftSide.Size = UDim2.new(0.25, 0, 1, 0)
	custLeftSide.Position = UDim2.new(0.05, 0, 0, 0)
	custLeftSide.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	custLeftSide.BackgroundTransparency = 0.1
	custLeftSide.ScrollBarThickness = 6
	custLeftSide.ScrollBarImageColor3 = Color3.fromRGB(218, 165, 32)
	local leftStroke = Instance.new("UIStroke")
	leftStroke.Color = Color3.fromRGB(218, 165, 32)
	leftStroke.Thickness = 2
	leftStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	leftStroke.Parent = custLeftSide
	UIUtils.addCorner(custLeftSide, 8)
	UIUtils.addPadding(custLeftSide, 10)
	UIUtils.addListLayout(custLeftSide, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	custLeftSide.Parent = customizationMenu

	local custOptions = {"Skin Color", "Hair Color", "Face Options", "Outfits", "Accessories"}
	for _, opt in ipairs(custOptions) do
		local btn = UIUtils.createButton(opt:gsub("%s+", "") .. "Button", opt, custLeftSide)
		btn.Size = UDim2.new(1, 0, 0, 50)
	end

	local custRightSide = Instance.new("Frame")
	custRightSide.Name = "RightSide"
	custRightSide.Size = UDim2.new(0.25, 0, 1, 0)
	custRightSide.Position = UDim2.new(0.7, 0, 0, 0)
	custRightSide.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	custRightSide.BackgroundTransparency = 0.1
	local rightStroke = Instance.new("UIStroke")
	rightStroke.Color = Color3.fromRGB(218, 165, 32)
	rightStroke.Thickness = 2
	rightStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	rightStroke.Parent = custRightSide
	UIUtils.addCorner(custRightSide, 8)
	UIUtils.addPadding(custRightSide, 10)
	UIUtils.addListLayout(custRightSide, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	custRightSide.Parent = customizationMenu

	local hairInputs = {}
	for i = 1, 5 do
		local hairInput = Instance.new("TextBox")
		hairInput.Name = "HairID" .. i
		hairInput.Size = UDim2.new(1, 0, 0.1, 0)
		hairInput.Text = ""
		hairInput.PlaceholderText = "Hair ID " .. i
		hairInput.Font = Enum.Font.Oswald
		hairInput.TextScaled = true
		hairInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		hairInput.TextColor3 = Color3.fromRGB(240, 240, 240)
		local inputStroke = Instance.new("UIStroke")
		inputStroke.Color = Color3.fromRGB(218, 165, 32)
		inputStroke.Thickness = 1
		inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		inputStroke.Parent = hairInput
		UIUtils.addCorner(hairInput, 6)
		hairInput.Parent = custRightSide
		table.insert(hairInputs, hairInput)
	end

	local applyHair = UIUtils.createButton("ApplyHair", "Apply Hair IDs", custRightSide)
	applyHair.Size = UDim2.new(1, 0, 0.1, 0)
	applyHair.BackgroundColor3 = Color3.fromRGB(100, 80, 20)

	local resetHair = UIUtils.createButton("ResetHair", "Reset Hair", custRightSide)
	resetHair.Size = UDim2.new(1, 0, 0.1, 0)

	local classesMenu = Instance.new("Frame")
	classesMenu.Name = "ClassesMenu"
	classesMenu.AnchorPoint = Vector2.new(0.5, 0.5)
	classesMenu.Size = UDim2.new(0.8, 0, 0.7, 0)
	classesMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
	classesMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	local classesStroke = Instance.new("UIStroke")
	classesStroke.Color = Color3.fromRGB(218, 165, 32)
	classesStroke.Thickness = 2
	classesStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	classesStroke.Parent = classesMenu
	UIUtils.addCorner(classesMenu, 12)
	classesMenu.Visible = false
	classesMenu.Parent = playerMenu
	pMenuFrames["Classes"] = classesMenu

	local classesList = Instance.new("ScrollingFrame")
	classesList.Name = "ClassesList"
	classesList.Size = UDim2.new(0.35, 0, 0.9, 0)
	classesList.Position = UDim2.new(0.05, 0, 0.05, 0)
	classesList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	classesList.ScrollBarImageColor3 = Color3.fromRGB(218, 165, 32)
	UIUtils.addCorner(classesList, 8)
	classesList.Parent = classesMenu

	local classesDesc = Instance.new("TextLabel")
	classesDesc.Name = "ClassesDescription"
	classesDesc.Size = UDim2.new(0.5, 0, 0.9, 0)
	classesDesc.Position = UDim2.new(0.45, 0, 0.05, 0)
	classesDesc.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	classesDesc.TextColor3 = Color3.fromRGB(240, 240, 240)
	classesDesc.Text = "Class Descriptions..."
	classesDesc.TextWrapped = true
	classesDesc.Font = Enum.Font.Gotham
	classesDesc.TextScaled = true
	local descConstraint = Instance.new("UITextSizeConstraint")
	descConstraint.MaxTextSize = 20
	descConstraint.Parent = classesDesc
	classesDesc.TextYAlignment = Enum.TextYAlignment.Top
	classesDesc.TextXAlignment = Enum.TextXAlignment.Left
	UIUtils.addPadding(classesDesc, 10)
	UIUtils.addCorner(classesDesc, 8)
	classesDesc.Parent = classesMenu

	local perksMenu = Instance.new("Frame")
	perksMenu.Name = "PerksMenu"
	perksMenu.AnchorPoint = Vector2.new(0.5, 0.5)
	perksMenu.Size = UDim2.new(0.8, 0, 0.7, 0)
	perksMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
	perksMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	local perksStroke = Instance.new("UIStroke")
	perksStroke.Color = Color3.fromRGB(218, 165, 32)
	perksStroke.Thickness = 2
	perksStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	perksStroke.Parent = perksMenu
	UIUtils.addCorner(perksMenu, 12)
	perksMenu.Visible = false
	perksMenu.Parent = playerMenu
	pMenuFrames["Perks"] = perksMenu

	local perksDesc = Instance.new("TextLabel")
	perksDesc.Name = "PerksDescription"
	perksDesc.Size = UDim2.new(0.3, 0, 0.9, 0)
	perksDesc.Position = UDim2.new(0.025, 0, 0.05, 0)
	perksDesc.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	perksDesc.TextColor3 = Color3.fromRGB(240, 240, 240)
	perksDesc.Text = "Perk Details..."
	perksDesc.TextWrapped = true
	perksDesc.Font = Enum.Font.Gotham
	perksDesc.TextScaled = true
	local perkDescConstraint = Instance.new("UITextSizeConstraint")
	perkDescConstraint.MaxTextSize = 18
	perkDescConstraint.Parent = perksDesc
	UIUtils.addCorner(perksDesc, 8)
	UIUtils.addPadding(perksDesc, 10)
	perksDesc.TextYAlignment = Enum.TextYAlignment.Top
	perksDesc.Parent = perksMenu

	local perksList = Instance.new("ScrollingFrame")
	perksList.Name = "PerksList"
	perksList.Size = UDim2.new(0.3, 0, 0.9, 0)
	perksList.Position = UDim2.new(0.35, 0, 0.05, 0)
	perksList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	perksList.ScrollBarImageColor3 = Color3.fromRGB(218, 165, 32)
	UIUtils.addCorner(perksList, 8)
	perksList.Parent = perksMenu

	local equippedPerks = Instance.new("Frame")
	equippedPerks.Name = "EquippedPerks"
	equippedPerks.Size = UDim2.new(0.3, 0, 0.9, 0)
	equippedPerks.Position = UDim2.new(0.675, 0, 0.05, 0)
	equippedPerks.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	UIUtils.addCorner(equippedPerks, 8)
	UIUtils.addListLayout(equippedPerks, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	UIUtils.addPadding(equippedPerks, 10)
	equippedPerks.Parent = perksMenu

	for i = 1, 5 do
		local slot = Instance.new("Frame")
		slot.Name = "Slot" .. i
		slot.Size = UDim2.new(1, 0, 0.18, 0)
		slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		local slotStroke = Instance.new("UIStroke")
		slotStroke.Color = Color3.fromRGB(218, 165, 32)
		slotStroke.Thickness = 1
		slotStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		slotStroke.Parent = slot
		UIUtils.addCorner(slot, 6)
		slot.Parent = equippedPerks
	end

	for pMenu, btn in pairs(pMenuButtons) do
		btn.MouseButton1Click:Connect(function()
			for k, f in pairs(pMenuFrames) do
				f.Visible = (k == pMenu)
			end
		end)
	end

	playerFinishBtn.MouseButton1Click:Connect(function()
		playerMenu.Visible = false
		bottomNavContainer.Visible = true
	end)

	applyHair.MouseButton1Click:Connect(function()
		local ids = {}
		for _, input in ipairs(hairInputs) do
			local text = input.Text:gsub("%s+", "")
			if text ~= "" and tonumber(text) then
				table.insert(ids, text)
			end
		end
		updateHairEvent:FireServer("Custom", table.concat(ids, ","))
	end)

	resetHair.MouseButton1Click:Connect(function()
		for _, input in ipairs(hairInputs) do
			input.Text = ""
		end
		updateHairEvent:FireServer("Default")
	end)

	return playerMenu
end

return PlayerMenuBuilder