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
coinsLabel.Size = UDim2.new(0, 200, 0, 50)
coinsLabel.Position = UDim2.new(1, -210, 0, 10)
coinsLabel.Text = "Coins: 0"
coinsLabel.TextScaled = true
coinsLabel.BackgroundTransparency = 0.5
coinsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
coinsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UIUtils.addCorner(coinsLabel, 6)
coinsLabel.Parent = screenGui

local bottomNavContainer = Instance.new("Frame")
bottomNavContainer.Name = "BottomNavContainer"
bottomNavContainer.Size = UDim2.new(0.5, 0, 0, 70)
bottomNavContainer.Position = UDim2.new(0.25, 0, 1, -90)
bottomNavContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
bottomNavContainer.BackgroundTransparency = 0.2
UIUtils.addCorner(bottomNavContainer, 12)
bottomNavContainer.Parent = screenGui

UIUtils.addListLayout(bottomNavContainer, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 10)
UIUtils.addPadding(bottomNavContainer, 10)

local menus = {"Party", "Player", "Goals", "Shop", "Logs"}
local menuFrames = {}
local menuButtons = {}

for i, menu in ipairs(menus) do
	local btn = UIUtils.createButton(menu .. "Button", menu, bottomNavContainer)
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.LayoutOrder = i
	menuButtons[menu] = btn
end

local playerMenu = PlayerMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
menuFrames["Player"] = playerMenu

local popups = PopupBuilder.build(screenGui, UIUtils, bottomNavContainer)
for name, frame in pairs(popups) do
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