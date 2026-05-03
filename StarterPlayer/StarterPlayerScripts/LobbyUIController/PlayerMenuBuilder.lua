-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local updateHairEvent = ReplicatedStorage:WaitForChild("UpdateHairEvent")
local CustomizationFolder = ReplicatedStorage:WaitForChild("Customization")

local PlayerMenuBuilder = {}

-- Helper to make clean wrapped scrolling frames to prevent clipping outlines
local function createWrappedScrollList(parent, name, size, position, anchorPoint)
	local wrapper = Instance.new("Frame")
	wrapper.Name = name .. "Wrapper"
	wrapper.Size = size
	wrapper.Position = position
	wrapper.AnchorPoint = anchorPoint or Vector2.new(0, 0)
	wrapper.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	wrapper.BackgroundTransparency = 0.1
	wrapper.Parent = parent

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(218, 165, 32)
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = wrapper

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = wrapper

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Color3.fromRGB(218, 165, 32)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = wrapper

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = scroll

	return wrapper, scroll
end

local function createSectionTitle(parent, text)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 25)
	title.BackgroundTransparency = 1
	title.Text = text
	title.TextColor3 = Color3.fromRGB(240, 240, 240)
	title.Font = Enum.Font.Oswald
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = parent
	return title
end

local function createColorGrid(parent, colors, eventAction)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.BackgroundTransparency = 1
	container.Parent = parent

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 35, 0, 35)
	grid.CellPadding = UDim2.new(0, 10, 0, 10)
	grid.FillDirection = Enum.FillDirection.Horizontal
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = container

	for i, color in ipairs(colors) do
		local cBtn = Instance.new("TextButton")
		cBtn.Text = ""
		cBtn.BackgroundColor3 = color
		cBtn.LayoutOrder = i
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = cBtn
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(240, 240, 240)
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = cBtn
		cBtn.Parent = container

		if eventAction then
			cBtn.MouseButton1Click:Connect(function()
				local r = math.floor(color.R * 255)
				local g = math.floor(color.G * 255)
				local b = math.floor(color.B * 255)
				updateHairEvent:FireServer(eventAction, r..","..g..","..b)
			end)
		end
	end
end

local function createCyclicalOption(parent, titleText, folderName, UIUtils)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 40)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.Text = titleText
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.Oswald
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local controls = Instance.new("Frame")
	controls.Size = UDim2.new(0.6, 0, 1, 0)
	controls.Position = UDim2.new(0.4, 0, 0, 0)
	controls.BackgroundTransparency = 1
	controls.Parent = container

	local leftBtn = UIUtils.createButton("L", "<", controls)
	leftBtn.Size = UDim2.new(0.25, 0, 1, 0)

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(0.5, 0, 1, 0)
	valLabel.Position = UDim2.new(0.25, 0, 0, 0)
	valLabel.TextColor3 = Color3.new(1, 1, 1)
	valLabel.Font = Enum.Font.Gotham
	valLabel.TextScaled = true
	valLabel.BackgroundTransparency = 1
	valLabel.Parent = controls

	local rightBtn = UIUtils.createButton("R", ">", controls)
	rightBtn.Size = UDim2.new(0.25, 0, 1, 0)
	rightBtn.Position = UDim2.new(0.75, 0, 0, 0)

	local folder = CustomizationFolder:FindFirstChild(folderName)
	local options = folder and folder:GetChildren() or {}
	table.sort(options, function(a, b) return a.Name < b.Name end)

	local maxOpt = #options
	if maxOpt == 0 then
		options = {{Name = "None"}}
		maxOpt = 1
	end

	local current = 1

	local function updateSelection()
		valLabel.Text = options[current].Name
		if options[current].Name ~= "None" then
			updateHairEvent:FireServer(folderName, options[current].Name)
		end
	end

	leftBtn.MouseButton1Click:Connect(function()
		current = current - 1
		if current < 1 then current = maxOpt end
		updateSelection()
	end)

	rightBtn.MouseButton1Click:Connect(function()
		current = current + 1
		if current > maxOpt then current = 1 end
		updateSelection()
	end)

	valLabel.Text = options[current].Name
end

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
	playerTopNav.Size = UDim2.new(0.7, 0, 0.12, 0)
	playerTopNav.Position = UDim2.new(0.5, 0, 0.02, 0)
	playerTopNav.BackgroundTransparency = 1 
	UIUtils.addListLayout(playerTopNav, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 20)
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
	playerFinishBtn.Size = UDim2.new(0.25, 0, 0.08, 0)
	playerFinishBtn.Position = UDim2.new(0.5, 0, 0.95, 0)
	playerFinishBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)

	-- ==========================================
	-- CUSTOMIZATION MENU (Strict Left/Right, Open Center)
	-- ==========================================
	local customizationMenu = Instance.new("Frame")
	customizationMenu.Name = "CustomizationMenu"
	customizationMenu.Size = UDim2.new(1, 0, 1, 0)
	customizationMenu.BackgroundTransparency = 1
	customizationMenu.Visible = true
	customizationMenu.Parent = playerMenu
	pMenuFrames["Customization"] = customizationMenu

	local custLeftWrapper, custLeftSide = createWrappedScrollList(customizationMenu, "LeftSide", UDim2.new(0.28, 0, 0.75, 0), UDim2.new(0.02, 0, 0.15, 0))
	UIUtils.addListLayout(custLeftSide, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 15)

	local custRightWrapper = Instance.new("Frame")
	custRightWrapper.Name = "RightSideWrapper"
	custRightWrapper.Size = UDim2.new(0.28, 0, 0.75, 0)
	custRightWrapper.Position = UDim2.new(0.98, 0, 0.15, 0)
	custRightWrapper.AnchorPoint = Vector2.new(1, 0)
	custRightWrapper.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	custRightWrapper.BackgroundTransparency = 0.1
	local crStroke = Instance.new("UIStroke", custRightWrapper)
	crStroke.Color = Color3.fromRGB(218, 165, 32)
	crStroke.Thickness = 2
	crStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIUtils.addCorner(custRightWrapper, 8)
	custRightWrapper.Parent = customizationMenu

	-- Natural Palettes
	local skinColors = {
		Color3.fromRGB(255, 224, 196), Color3.fromRGB(241, 194, 125), Color3.fromRGB(224, 172, 105),
		Color3.fromRGB(198, 134, 66), Color3.fromRGB(141, 85, 36), Color3.fromRGB(97, 54, 19), 
		Color3.fromRGB(61, 34, 15), Color3.fromRGB(43, 23, 10)
	}
	local hairColors = {
		Color3.fromRGB(9, 8, 6), Color3.fromRGB(44, 34, 43), Color3.fromRGB(113, 99, 90), Color3.fromRGB(183, 166, 158),
		Color3.fromRGB(220, 208, 186), Color3.fromRGB(255, 250, 230), Color3.fromRGB(143, 43, 43), Color3.fromRGB(181, 82, 57),
		Color3.fromRGB(220, 160, 110), Color3.fromRGB(120, 120, 120), Color3.fromRGB(200, 200, 200)
	}
	local eyeColors = {
		Color3.fromRGB(99, 78, 52), Color3.fromRGB(45, 32, 14), Color3.fromRGB(134, 184, 219),
		Color3.fromRGB(105, 145, 163), Color3.fromRGB(87, 110, 83), Color3.fromRGB(112, 139, 93),
		Color3.fromRGB(152, 154, 155)
	}

	-- Left Area
	createSectionTitle(custLeftSide, "Skin Color")
	createColorGrid(custLeftSide, skinColors, "SkinColor")

	createSectionTitle(custLeftSide, "Hair Color")
	createColorGrid(custLeftSide, hairColors, "HairColor")

	createSectionTitle(custLeftSide, "Eye Color")
	createColorGrid(custLeftSide, eyeColors, nil)

	createSectionTitle(custLeftSide, "Facial Features")
	createCyclicalOption(custLeftSide, "Eyebrows", "Eyebrows", UIUtils)
	createCyclicalOption(custLeftSide, "Eyes", "Eyes", UIUtils)
	createCyclicalOption(custLeftSide, "Nose", "Nose", UIUtils)
	createCyclicalOption(custLeftSide, "Mouth", "Mouth", UIUtils)

	createSectionTitle(custLeftSide, "Equipment")
	local equipmentControls = Instance.new("Frame")
	equipmentControls.Size = UDim2.new(1, 0, 0, 50)
	equipmentControls.BackgroundTransparency = 1
	UIUtils.addListLayout(equipmentControls, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 5)
	equipmentControls.Parent = custLeftSide

	local rightPanels = {}
	local rpt = {"Hair IDs", "Outfits", "Accessories"}

	for _, mode in ipairs(rpt) do
		local btn = UIUtils.createButton(mode.."Btn", mode, equipmentControls)
		btn.Size = UDim2.new(0.32, 0, 1, 0)
		btn.UITextSizeConstraint.MaxTextSize = 16

		local pnl = Instance.new("ScrollingFrame")
		pnl.Name = mode.."Panel"
		pnl.Size = UDim2.new(1, 0, 1, 0)
		pnl.BackgroundTransparency = 1
		pnl.ScrollBarThickness = 6
		pnl.ScrollBarImageColor3 = Color3.fromRGB(218, 165, 32)
		pnl.AutomaticCanvasSize = Enum.AutomaticSize.Y
		pnl.CanvasSize = UDim2.new(0, 0, 0, 0)
		pnl.Visible = (mode == "Hair IDs")
		UIUtils.addPadding(pnl, 10)
		pnl.Parent = custRightWrapper
		rightPanels[mode] = pnl

		btn.MouseButton1Click:Connect(function()
			for n, p in pairs(rightPanels) do p.Visible = (n == mode) end
		end)
	end

	-- Hair Panel Setup
	UIUtils.addListLayout(rightPanels["Hair IDs"], Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	createSectionTitle(rightPanels["Hair IDs"], "Equip Custom Hair")
	local hairInputs = {}
	for i = 1, 5 do -- Fixed to 5 Slots
		local hairInput = Instance.new("TextBox")
		hairInput.Name = "HairID" .. i
		hairInput.Size = UDim2.new(1, 0, 0, 45)
		hairInput.Text = ""
		hairInput.PlaceholderText = "Hair ID " .. i
		hairInput.Font = Enum.Font.Oswald
		hairInput.TextScaled = true
		hairInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		hairInput.TextColor3 = Color3.fromRGB(240, 240, 240)
		local inputStroke = Instance.new("UIStroke", hairInput)
		inputStroke.Color = Color3.fromRGB(218, 165, 32)
		inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIUtils.addCorner(hairInput, 6)
		hairInput.Parent = rightPanels["Hair IDs"]
		table.insert(hairInputs, hairInput)
	end

	local applyHair = UIUtils.createButton("ApplyHair", "Apply Hair IDs", rightPanels["Hair IDs"])
	applyHair.Size = UDim2.new(1, 0, 0, 45)
	applyHair.BackgroundColor3 = Color3.fromRGB(30, 120, 30)

	local resetHair = UIUtils.createButton("ResetHair", "Clear Hair", rightPanels["Hair IDs"])
	resetHair.Size = UDim2.new(1, 0, 0, 45)

	applyHair.MouseButton1Click:Connect(function()
		local ids = {}
		for _, input in ipairs(hairInputs) do
			local text = input.Text:gsub("%s+", "")
			if text ~= "" and tonumber(text) then table.insert(ids, text) end
		end
		updateHairEvent:FireServer("CustomHair", table.concat(ids, ","))
	end)

	resetHair.MouseButton1Click:Connect(function()
		for _, input in ipairs(hairInputs) do input.Text = "" end
		updateHairEvent:FireServer("DefaultHair")
	end)

	-- Viewport Generator Function
	local function createOutfitViewport(parent, shirtId, pantsId, accessoryInstance, itemName, layoutOrder)
		local btn = Instance.new("TextButton")
		btn.Text = ""
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.LayoutOrder = layoutOrder or 1
		UIUtils.addCorner(btn, 8)
		local stroke = Instance.new("UIStroke", btn)
		stroke.Color = Color3.fromRGB(218, 165, 32)
		stroke.Thickness = 2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local vp = Instance.new("ViewportFrame", btn)
		vp.Size = UDim2.new(1, 0, 0.85, 0)
		vp.BackgroundTransparency = 1
		UIUtils.addCorner(vp, 8)

		local titleLabel = Instance.new("TextLabel", btn)
		titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
		titleLabel.Position = UDim2.new(0, 0, 0.85, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = itemName or "Preset"
		titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		titleLabel.Font = Enum.Font.Oswald
		titleLabel.TextScaled = true
		UIUtils.addPadding(titleLabel, 2)

		local cam = Instance.new("Camera")
		vp.CurrentCamera = cam
		cam.Parent = vp

		task.spawn(function()
			local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
			char.Archivable = true
			local dummy = char:Clone()

			for _, v in ipairs(dummy:GetDescendants()) do
				if v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end
			end

			-- Strip ALL current player accessories and clothing
			for _, v in ipairs(dummy:GetChildren()) do
				if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
					v:Destroy()
				end
			end

			local wm = Instance.new("WorldModel", vp)
			dummy.Parent = wm

			local hum = dummy:FindFirstChild("Humanoid")
			if hum then
				hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

				local desc = hum:GetAppliedDescription()
				local whiteColor = Color3.fromRGB(255, 255, 255)
				desc.HeadColor = whiteColor
				desc.LeftArmColor = whiteColor
				desc.RightArmColor = whiteColor
				desc.LeftLegColor = whiteColor
				desc.RightLegColor = whiteColor
				desc.TorsoColor = whiteColor
				pcall(function() hum:ApplyDescription(desc) end)

				if accessoryInstance then
					-- MANUAL WELD LOGIC FOR VIEWPORT: Bypass AddAccessory physics requirements
					if accessoryInstance ~= "None" then
						local accClone = accessoryInstance:Clone()
						local handle = accClone:FindFirstChild("Handle")

						if handle then
							handle.Anchored = false
							local accAtt = handle:FindFirstChildWhichIsA("Attachment")
							if accAtt then
								local dummyAtt
								for _, v in ipairs(dummy:GetDescendants()) do
									if v:IsA("Attachment") and v.Name == accAtt.Name and v.Parent:IsA("BasePart") then
										dummyAtt = v
										break
									end
								end

								if dummyAtt then
									handle.CFrame = dummyAtt.Parent.CFrame * dummyAtt.CFrame * accAtt.CFrame:Inverse()
									local weld = Instance.new("WeldConstraint")
									weld.Part0 = dummyAtt.Parent
									weld.Part1 = handle
									weld.Parent = handle
								end
							end
						end
						accClone.Parent = dummy
					end
				else
					local parsedShirt = shirtId and string.match(tostring(shirtId), "%d+") or "125195176"
					local parsedPants = pantsId and string.match(tostring(pantsId), "%d+") or "125195172"

					local shirt = Instance.new("Shirt", dummy)
					shirt.ShirtTemplate = "rbxassetid://" .. parsedShirt

					local pants = Instance.new("Pants", dummy)
					pants.PantsTemplate = "rbxassetid://" .. parsedPants
				end
			end

			-- Force BodyColors and BaseParts to pure white for clear viewing
			local whiteColor = Color3.fromRGB(255, 255, 255)
			local bodyColors = dummy:FindFirstChildWhichIsA("BodyColors")
			if bodyColors then
				bodyColors.HeadColor3 = whiteColor
				bodyColors.LeftArmColor3 = whiteColor
				bodyColors.RightArmColor3 = whiteColor
				bodyColors.LeftLegColor3 = whiteColor
				bodyColors.RightLegColor3 = whiteColor
				bodyColors.TorsoColor3 = whiteColor
			end
			for _, part in ipairs(dummy:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Color = whiteColor
				end
			end

			local hrp = dummy:FindFirstChild("HumanoidRootPart")
			if hrp then
				cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, -6), hrp.Position)
			end

			local connection
			local angle = 0
			local baseCFrame = hrp and hrp.CFrame or CFrame.new()

			btn.MouseEnter:Connect(function()
				connection = RunService.RenderStepped:Connect(function(dt)
					if hrp then
						angle = angle + math.rad(90 * dt)
						hrp.CFrame = baseCFrame * CFrame.Angles(0, angle, 0)
					end
				end)
			end)
			btn.MouseLeave:Connect(function()
				if connection then connection:Disconnect() end
				angle = 0
				if hrp then hrp.CFrame = baseCFrame end
			end)

			btn.MouseButton1Click:Connect(function()
				if accessoryInstance then
					if accessoryInstance == "None" then
						updateHairEvent:FireServer("Accessory", "None")
					else
						updateHairEvent:FireServer("Accessory", accessoryInstance.Name)
					end
				else
					updateHairEvent:FireServer("Outfit", {ShirtTemplate = shirtId, PantsTemplate = pantsId})
				end
			end)
		end)

		btn.Parent = parent
	end

	-- Outfits Panel Setup
	UIUtils.addListLayout(rightPanels["Outfits"], Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	createSectionTitle(rightPanels["Outfits"], "Outfits")

	local oContainer = Instance.new("Frame")
	oContainer.Size = UDim2.new(1, 0, 0, 0)
	oContainer.AutomaticSize = Enum.AutomaticSize.Y
	oContainer.BackgroundTransparency = 1
	oContainer.Parent = rightPanels["Outfits"]

	local oGrid = Instance.new("UIGridLayout")
	oGrid.CellSize = UDim2.new(0, 130, 0, 160)
	oGrid.CellPadding = UDim2.new(0, 10, 0, 10)
	oGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	oGrid.SortOrder = Enum.SortOrder.LayoutOrder
	oGrid.Parent = oContainer

	local outfitsFolder = CustomizationFolder:FindFirstChild("Outfits")
	if outfitsFolder then
		local outfitNames = {}
		local outfitData = {}
		for _, item in ipairs(outfitsFolder:GetChildren()) do
			if not outfitData[item.Name] then 
				outfitData[item.Name] = {} 
				table.insert(outfitNames, item.Name)
			end
			if item:IsA("Shirt") then outfitData[item.Name].Shirt = item.ShirtTemplate end
			if item:IsA("Pants") then outfitData[item.Name].Pants = item.PantsTemplate end
		end

		table.sort(outfitNames, function(a, b)
			if a == "Default" then return true end
			if b == "Default" then return false end
			return a < b
		end)

		for i, name in ipairs(outfitNames) do
			local data = outfitData[name]
			createOutfitViewport(oContainer, data.Shirt, data.Pants, nil, name, i)
		end
	end

	-- Accessories Panel Setup
	UIUtils.addListLayout(rightPanels["Accessories"], Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	createSectionTitle(rightPanels["Accessories"], "Accessories")

	local aContainer = Instance.new("Frame")
	aContainer.Size = UDim2.new(1, 0, 0, 0)
	aContainer.AutomaticSize = Enum.AutomaticSize.Y
	aContainer.BackgroundTransparency = 1
	aContainer.Parent = rightPanels["Accessories"]

	local aGrid = Instance.new("UIGridLayout")
	aGrid.CellSize = UDim2.new(0, 130, 0, 160)
	aGrid.CellPadding = UDim2.new(0, 10, 0, 10)
	aGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	aGrid.SortOrder = Enum.SortOrder.LayoutOrder
	aGrid.Parent = aContainer

	-- Place the None option at the start (LayoutOrder = 0)
	createOutfitViewport(aContainer, nil, nil, "None", "None", 0)

	local accessoriesFolder = CustomizationFolder:FindFirstChild("Accessories")
	if accessoriesFolder then
		local accs = accessoriesFolder:GetChildren()
		table.sort(accs, function(a, b) return a.Name < b.Name end)

		for i, acc in ipairs(accs) do
			if acc:IsA("Accessory") then
				createOutfitViewport(aContainer, nil, nil, acc, acc.Name, i)
			end
		end
	end

	-- ==========================================
	-- CLASSES MENU (Popup Style)
	-- ==========================================
	local classesMenu = Instance.new("Frame")
	classesMenu.Name = "ClassesMenu"
	classesMenu.AnchorPoint = Vector2.new(0.5, 0.5)
	classesMenu.Size = UDim2.new(0.8, 0, 0.7, 0)
	classesMenu.Position = UDim2.new(0.5, 0, 0.55, 0)
	classesMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	classesMenu.BackgroundTransparency = 0.1
	local classesStroke = Instance.new("UIStroke", classesMenu)
	classesStroke.Color = Color3.fromRGB(218, 165, 32)
	classesStroke.Thickness = 2
	classesStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIUtils.addCorner(classesMenu, 12)
	UIUtils.addPadding(classesMenu, 15)
	classesMenu.Visible = false
	classesMenu.Parent = playerMenu
	pMenuFrames["Classes"] = classesMenu

	local classLeftWrapper, classLeftSide = createWrappedScrollList(classesMenu, "ClassesList", UDim2.new(0.35, 0, 1, 0), UDim2.new(0, 0, 0, 0))
	UIUtils.addListLayout(classLeftSide, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)

	local classRightWrapper = Instance.new("Frame")
	classRightWrapper.Size = UDim2.new(0.62, 0, 1, 0)
	classRightWrapper.Position = UDim2.new(0.38, 0, 0, 0)
	classRightWrapper.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	classRightWrapper.BackgroundTransparency = 0.1
	local crStroke = Instance.new("UIStroke", classRightWrapper)
	crStroke.Color = Color3.fromRGB(218, 165, 32)
	crStroke.Thickness = 2
	crStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIUtils.addCorner(classRightWrapper, 8)
	classRightWrapper.Parent = classesMenu

	local classesDesc = Instance.new("TextLabel")
	classesDesc.Size = UDim2.new(1, 0, 1, 0)
	classesDesc.BackgroundTransparency = 1
	classesDesc.TextColor3 = Color3.fromRGB(240, 240, 240)
	classesDesc.Text = "Select a class to view its details."
	classesDesc.TextWrapped = true
	classesDesc.Font = Enum.Font.Gotham
	classesDesc.TextScaled = true
	local descConstraint = Instance.new("UITextSizeConstraint", classesDesc)
	descConstraint.MaxTextSize = 22
	classesDesc.TextYAlignment = Enum.TextYAlignment.Top
	classesDesc.TextXAlignment = Enum.TextXAlignment.Left
	UIUtils.addPadding(classesDesc, 15)
	classesDesc.Parent = classRightWrapper

	local humanClassBtn = UIUtils.createButton("HumanClassBtn", "Human", classLeftSide)
	humanClassBtn.Size = UDim2.new(1, 0, 0, 60)
	humanClassBtn.MouseButton1Click:Connect(function()
		classesDesc.Text = "Class: Human\n\nA standard human with no innate supernatural abilities. You have balanced stats across the board, but lack specialized skills. A true blank slate."
	end)

	-- ==========================================
	-- PERKS MENU (Popup Style, 3 Columns)
	-- ==========================================
	local perksMenu = Instance.new("Frame")
	perksMenu.Name = "PerksMenu"
	perksMenu.AnchorPoint = Vector2.new(0.5, 0.5)
	perksMenu.Size = UDim2.new(0.8, 0, 0.7, 0)
	perksMenu.Position = UDim2.new(0.5, 0, 0.55, 0)
	perksMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	perksMenu.BackgroundTransparency = 0.1
	local perksStroke = Instance.new("UIStroke", perksMenu)
	perksStroke.Color = Color3.fromRGB(218, 165, 32)
	perksStroke.Thickness = 2
	perksStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIUtils.addCorner(perksMenu, 12)
	UIUtils.addPadding(perksMenu, 15)
	perksMenu.Visible = false
	perksMenu.Parent = playerMenu
	pMenuFrames["Perks"] = perksMenu

	-- Left: Description & Equip
	local perkLeftWrapper = Instance.new("Frame")
	perkLeftWrapper.Size = UDim2.new(0.3, 0, 1, 0)
	perkLeftWrapper.Position = UDim2.new(0, 0, 0, 0)
	perkLeftWrapper.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	perkLeftWrapper.BackgroundTransparency = 0.1
	local plStroke = Instance.new("UIStroke", perkLeftWrapper)
	plStroke.Color = Color3.fromRGB(218, 165, 32)
	plStroke.Thickness = 2
	plStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIUtils.addCorner(perkLeftWrapper, 8)
	perkLeftWrapper.Parent = perksMenu

	local perksDesc = Instance.new("TextLabel")
	perksDesc.Size = UDim2.new(1, 0, 0.85, 0)
	perksDesc.BackgroundTransparency = 1
	perksDesc.TextColor3 = Color3.fromRGB(240, 240, 240)
	perksDesc.Text = "Select a perk to view details."
	perksDesc.TextWrapped = true
	perksDesc.Font = Enum.Font.Gotham
	perksDesc.TextScaled = true
	local perkDescConstraint = Instance.new("UITextSizeConstraint", perksDesc)
	perkDescConstraint.MaxTextSize = 20
	perksDesc.TextYAlignment = Enum.TextYAlignment.Top
	perksDesc.TextXAlignment = Enum.TextXAlignment.Left
	UIUtils.addPadding(perksDesc, 15)
	perksDesc.Parent = perkLeftWrapper

	local equipPerkBtn = UIUtils.createButton("EquipPerkBtn", "Equip Perk", perkLeftWrapper)
	equipPerkBtn.AnchorPoint = Vector2.new(0.5, 1)
	equipPerkBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
	equipPerkBtn.Position = UDim2.new(0.5, 0, 0.95, 0)
	equipPerkBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)

	-- Middle: Perk List
	local perkMidWrapper, perksList = createWrappedScrollList(perksMenu, "PerksList", UDim2.new(0.32, 0, 1, 0), UDim2.new(0.34, 0, 0, 0))
	UIUtils.addListLayout(perksList, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)

	-- Right: Equipped Perks
	local perkRightWrapper, equippedPerks = createWrappedScrollList(perksMenu, "EquippedPerks", UDim2.new(0.3, 0, 1, 0), UDim2.new(0.7, 0, 0, 0))
	UIUtils.addListLayout(equippedPerks, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	createSectionTitle(equippedPerks, "Equipped (Max 5)")

	for i = 1, 5 do
		local slot = Instance.new("Frame")
		slot.Name = "Slot" .. i
		slot.Size = UDim2.new(1, 0, 0, 50)
		slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		local slotStroke = Instance.new("UIStroke", slot)
		slotStroke.Color = Color3.fromRGB(218, 165, 32)
		slotStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIUtils.addCorner(slot, 6)
		local lbl = Instance.new("TextLabel", slot)
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = "Empty Slot"
		lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
		lbl.Font = Enum.Font.Oswald
		lbl.TextScaled = true
		UIUtils.addPadding(lbl, 10)
		slot.Parent = equippedPerks
	end

	local toughBtn = UIUtils.createButton("ToughnessPerkBtn", "Toughness", perksList)
	toughBtn.Size = UDim2.new(1, 0, 0, 50)
	toughBtn.MouseButton1Click:Connect(function()
		perksDesc.Text = "Perk: Toughness\n\nGrants a small bonus to your maximum Health. A good starting perk for surviving early encounters."
	end)

	-- ==========================================
	-- WIRING / LOGIC
	-- ==========================================
	for pMenu, btn in pairs(pMenuButtons) do
		btn.MouseButton1Click:Connect(function()
			for k, f in pairs(pMenuFrames) do f.Visible = (k == pMenu) end
		end)
	end

	playerFinishBtn.MouseButton1Click:Connect(function()
		playerMenu.Visible = false
		bottomNavContainer.Visible = true
	end)

	return playerMenu
end

return PlayerMenuBuilder