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
	playerTopNav.Size = UDim2.new(0.6, 0, 0, 60)
	playerTopNav.Position = UDim2.new(0.2, 0, 0, 20)
	playerTopNav.BackgroundTransparency = 1 
	UIUtils.addListLayout(playerTopNav, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 15)
	UIUtils.addPadding(playerTopNav, 10)
	playerTopNav.Parent = playerMenu

	local pMenus = {"Customization", "Classes", "Perks"}
	local pMenuFrames = {}
	local pMenuButtons = {}

	for i, pMenu in ipairs(pMenus) do
		local btn = UIUtils.createButton(pMenu .. "Button", pMenu, playerTopNav)
		btn.Size = UDim2.new(0, 150, 1, 0)
		pMenuButtons[pMenu] = btn
	end

	local playerFinishBtn = UIUtils.createButton("FinishButton", "Finish", playerMenu)
	playerFinishBtn.Size = UDim2.new(0, 200, 0, 60)
	playerFinishBtn.Position = UDim2.new(0.5, -100, 1, -80)
	playerFinishBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

	local customizationMenu = Instance.new("Frame")
	customizationMenu.Name = "CustomizationMenu"
	customizationMenu.Size = UDim2.new(1, 0, 1, -180)
	customizationMenu.Position = UDim2.new(0, 0, 0, 100)
	customizationMenu.BackgroundTransparency = 1
	customizationMenu.Visible = true
	customizationMenu.Parent = playerMenu
	pMenuFrames["Customization"] = customizationMenu

	local custLeftSide = Instance.new("ScrollingFrame")
	custLeftSide.Name = "LeftSide"
	custLeftSide.Size = UDim2.new(0.2, 0, 1, -20)
	custLeftSide.Position = UDim2.new(0.05, 0, 0, 10)
	custLeftSide.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	custLeftSide.BackgroundTransparency = 0.2
	custLeftSide.ScrollBarThickness = 6
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
	custRightSide.Size = UDim2.new(0.2, 0, 1, -20)
	custRightSide.Position = UDim2.new(0.75, 0, 0, 10)
	custRightSide.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	custRightSide.BackgroundTransparency = 0.2
	UIUtils.addCorner(custRightSide, 8)
	UIUtils.addPadding(custRightSide, 10)
	UIUtils.addListLayout(custRightSide, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	custRightSide.Parent = customizationMenu

	local hairInputs = {}
	for i = 1, 5 do
		local hairInput = Instance.new("TextBox")
		hairInput.Name = "HairID" .. i
		hairInput.Size = UDim2.new(1, 0, 0, 40)
		hairInput.PlaceholderText = "Hair ID " .. i
		hairInput.Font = Enum.Font.Gotham
		hairInput.TextScaled = true
		hairInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		hairInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		UIUtils.addCorner(hairInput, 6)
		hairInput.Parent = custRightSide
		table.insert(hairInputs, hairInput)
	end

	local applyHair = UIUtils.createButton("ApplyHair", "Apply Hair IDs", custRightSide)
	applyHair.Size = UDim2.new(1, 0, 0, 50)
	applyHair.BackgroundColor3 = Color3.fromRGB(50, 150, 50)

	local resetHair = UIUtils.createButton("ResetHair", "Reset Hair", custRightSide)
	resetHair.Size = UDim2.new(1, 0, 0, 50)

	local classesMenu = Instance.new("Frame")
	classesMenu.Name = "ClassesMenu"
	classesMenu.Size = UDim2.new(0.8, 0, 0.7, 0)
	classesMenu.Position = UDim2.new(0.1, 0, 0.15, 0)
	classesMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	UIUtils.addCorner(classesMenu, 12)
	classesMenu.Visible = false
	classesMenu.Parent = playerMenu
	pMenuFrames["Classes"] = classesMenu

	local classesList = Instance.new("ScrollingFrame")
	classesList.Name = "ClassesList"
	classesList.Size = UDim2.new(0.4, -10, 1, -20)
	classesList.Position = UDim2.new(0, 10, 0, 10)
	classesList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	UIUtils.addCorner(classesList, 8)
	classesList.Parent = classesMenu

	local classesDesc = Instance.new("TextLabel")
	classesDesc.Name = "ClassesDescription"
	classesDesc.Size = UDim2.new(0.6, -20, 1, -20)
	classesDesc.Position = UDim2.new(0.4, 10, 0, 10)
	classesDesc.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	classesDesc.TextColor3 = Color3.fromRGB(220, 220, 220)
	classesDesc.Text = "Class Descriptions..."
	classesDesc.TextWrapped = true
	classesDesc.Font = Enum.Font.Gotham
	classesDesc.TextSize = 18
	classesDesc.TextYAlignment = Enum.TextYAlignment.Top
	classesDesc.TextXAlignment = Enum.TextXAlignment.Left
	UIUtils.addPadding(classesDesc, 10)
	UIUtils.addCorner(classesDesc, 8)
	classesDesc.Parent = classesMenu

	local perksMenu = Instance.new("Frame")
	perksMenu.Name = "PerksMenu"
	perksMenu.Size = UDim2.new(0.8, 0, 0.7, 0)
	perksMenu.Position = UDim2.new(0.1, 0, 0.15, 0)
	perksMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	UIUtils.addCorner(perksMenu, 12)
	perksMenu.Visible = false
	perksMenu.Parent = playerMenu
	pMenuFrames["Perks"] = perksMenu

	local perksDesc = Instance.new("TextLabel")
	perksDesc.Name = "PerksDescription"
	perksDesc.Size = UDim2.new(0.33, -10, 1, -20)
	perksDesc.Position = UDim2.new(0, 10, 0, 10)
	perksDesc.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	perksDesc.TextColor3 = Color3.fromRGB(220, 220, 220)
	perksDesc.Text = "Perk Details..."
	perksDesc.TextWrapped = true
	perksDesc.Font = Enum.Font.Gotham
	perksDesc.TextSize = 16
	UIUtils.addCorner(perksDesc, 8)
	UIUtils.addPadding(perksDesc, 10)
	perksDesc.TextYAlignment = Enum.TextYAlignment.Top
	perksDesc.Parent = perksMenu

	local perksList = Instance.new("ScrollingFrame")
	perksList.Name = "PerksList"
	perksList.Size = UDim2.new(0.34, -10, 1, -20)
	perksList.Position = UDim2.new(0.33, 5, 0, 10)
	perksList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	UIUtils.addCorner(perksList, 8)
	perksList.Parent = perksMenu

	local equippedPerks = Instance.new("Frame")
	equippedPerks.Name = "EquippedPerks"
	equippedPerks.Size = UDim2.new(0.33, -10, 1, -20)
	equippedPerks.Position = UDim2.new(0.67, 0, 0, 10)
	equippedPerks.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	UIUtils.addCorner(equippedPerks, 8)
	UIUtils.addListLayout(equippedPerks, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	UIUtils.addPadding(equippedPerks, 10)
	equippedPerks.Parent = perksMenu

	for i = 1, 5 do
		local slot = Instance.new("Frame")
		slot.Name = "Slot" .. i
		slot.Size = UDim2.new(1, 0, 0, 60)
		slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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