-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local UIUtils = require(script:WaitForChild("UIUtils"))
local PlayerMenuBuilder = require(script:WaitForChild("PlayerMenuBuilder"))
local PopupBuilder = require(script:WaitForChild("PopupBuilder"))

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LobbyUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.Parent = player:WaitForChild("PlayerGui")

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsDisplay"
coinsLabel.AnchorPoint = Vector2.new(1, 0)
coinsLabel.Size = UDim2.new(0.15, 0, 0.06, 0)
coinsLabel.Position = UDim2.new(0.98, 0, 0.02, 0)
coinsLabel.Text = "Coins: 0"
coinsLabel.Font = Enum.Font.Oswald
coinsLabel.TextScaled = true
coinsLabel.BackgroundTransparency = 0.1
coinsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
coinsLabel.TextColor3 = Color3.fromRGB(218, 165, 32)
local coinsStroke = Instance.new("UIStroke")
coinsStroke.Color = Color3.fromRGB(218, 165, 32)
coinsStroke.Thickness = 2
coinsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
coinsStroke.Parent = coinsLabel
UIUtils.addCorner(coinsLabel, 6)
coinsLabel.Parent = screenGui

local bottomNavContainer = Instance.new("Frame")
bottomNavContainer.Name = "BottomNavContainer"
bottomNavContainer.AnchorPoint = Vector2.new(0.5, 1)
bottomNavContainer.Size = UDim2.new(0.6, 0, 0.1, 0)
bottomNavContainer.Position = UDim2.new(0.5, 0, 0.98, 0)
bottomNavContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
bottomNavContainer.BackgroundTransparency = 0.1
local navStroke = Instance.new("UIStroke")
navStroke.Color = Color3.fromRGB(218, 165, 32)
navStroke.Thickness = 2
navStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
navStroke.Parent = bottomNavContainer
UIUtils.addCorner(bottomNavContainer, 12)
bottomNavContainer.Parent = screenGui

UIUtils.addListLayout(bottomNavContainer, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 10)
UIUtils.addPadding(bottomNavContainer, 10)

local menus = {"Party", "Player", "Goals", "Shop", "Logs"}
local menuFrames = {}
local menuButtons = {}

for i, menu in ipairs(menus) do
	local btn = UIUtils.createButton(menu .. "Button", menu, bottomNavContainer)
	btn.Size = UDim2.new(0.18, 0, 1, 0)
	btn.LayoutOrder = i
	menuButtons[menu] = btn
end

local playerMenu = PlayerMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
menuFrames["Player"] = playerMenu

local popups = PopupBuilder.build(screenGui, UIUtils, bottomNavContainer)
for name, frame in popups do
	menuFrames[name] = frame
end

for _, menu in ipairs(menus) do
	menuButtons[menu].MouseButton1Click:Connect(function()
		for k, f in pairs(menuFrames) do
			f.Visible = (k == menu)
		end
		bottomNavContainer.Visible = false
	end)
end