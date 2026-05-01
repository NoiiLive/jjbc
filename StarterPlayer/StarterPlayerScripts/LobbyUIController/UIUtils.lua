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
	btn.Font = Enum.Font.Oswald
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.AutoButtonColor = true

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(218, 165, 32)
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn

	UIUtils.addCorner(btn, 6)
	btn.Parent = parent

	local textPad = Instance.new("UITextSizeConstraint")
	textPad.MaxTextSize = 28
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
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.new(0.5, 0, 0.7, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

	local bgStroke = Instance.new("UIStroke")
	bgStroke.Color = Color3.fromRGB(218, 165, 32)
	bgStroke.Thickness = 2
	bgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bgStroke.Parent = frame

	UIUtils.addCorner(frame, 12)
	frame.Parent = bg

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.1, 0)
	title.BackgroundTransparency = 1
	title.Text = name
	title.Font = Enum.Font.Oswald
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(218, 165, 32)
	title.Parent = frame

	local titleConstraint = Instance.new("UITextSizeConstraint")
	titleConstraint.MaxTextSize = 36
	titleConstraint.Parent = title

	local contentArea = Instance.new("ScrollingFrame")
	contentArea.Name = "ContentList"
	contentArea.AnchorPoint = Vector2.new(0.5, 0)
	contentArea.Size = UDim2.new(0.95, 0, 0.7, 0)
	contentArea.Position = UDim2.new(0.5, 0, 0.12, 0)
	contentArea.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	contentArea.ScrollBarImageColor3 = Color3.fromRGB(218, 165, 32)
	UIUtils.addCorner(contentArea, 8)
	contentArea.Parent = frame

	local closeBtn = UIUtils.createButton("CloseButton", "Close", frame)
	closeBtn.AnchorPoint = Vector2.new(0.5, 1)
	closeBtn.Size = UDim2.new(0.3, 0, 0.1, 0)
	closeBtn.Position = UDim2.new(0.5, 0, 0.95, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)

	closeBtn.MouseButton1Click:Connect(function()
		bg.Visible = false
		if bottomNavContainer then
			bottomNavContainer.Visible = true
		end
	end)

	return bg, frame, contentArea
end

return UIUtils