-- @ScriptType: ModuleScript
local UIUtils = {}

function UIUtils.addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

function UIUtils.addPadding(parent, padding)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, padding)
	pad.PaddingBottom = UDim.new(0, padding)
	pad.PaddingLeft = UDim.new(0, padding)
	pad.PaddingRight = UDim.new(0, padding)
	pad.Parent = parent
	return pad
end

function UIUtils.addListLayout(parent, fillDirection, horizontalAlignment, verticalAlignment, padding)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = fillDirection or Enum.FillDirection.Vertical
	layout.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = verticalAlignment or Enum.VerticalAlignment.Top
	layout.Padding = UDim.new(0, padding or 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = parent
	return layout
end

function UIUtils.createButton(name, text, parent)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = text
	btn.Font = Enum.Font.GothamSemibold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.AutoButtonColor = true
	UIUtils.addCorner(btn, 6)
	btn.Parent = parent

	local textPad = Instance.new("UITextSizeConstraint")
	textPad.MaxTextSize = 20
	textPad.Parent = btn

	return btn
end

function UIUtils.createStandardPopup(name, screenGui, bottomNavContainer)
	local bg = Instance.new("Frame")
	bg.Name = name .. "Menu"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundTransparency = 1 
	bg.Visible = false
	bg.Parent = screenGui

	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.Size = UDim2.new(0.5, 0, 0.6, 0)
	frame.Position = UDim2.new(0.25, 0, 0.2, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	UIUtils.addCorner(frame, 12)
	frame.Parent = bg

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = name
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Parent = frame

	local contentArea = Instance.new("ScrollingFrame")
	contentArea.Name = "ContentList"
	contentArea.Size = UDim2.new(1, -20, 1, -110)
	contentArea.Position = UDim2.new(0, 10, 0, 40)
	contentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	UIUtils.addCorner(contentArea, 8)
	contentArea.Parent = frame

	local closeBtn = UIUtils.createButton("CloseButton", "Close", frame)
	closeBtn.Size = UDim2.new(0, 150, 0, 40)
	closeBtn.Position = UDim2.new(0.5, -75, 1, -50)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

	closeBtn.MouseButton1Click:Connect(function()
		bg.Visible = false
		if bottomNavContainer then
			bottomNavContainer.Visible = true
		end
	end)

	return bg, frame, contentArea
end

return UIUtils