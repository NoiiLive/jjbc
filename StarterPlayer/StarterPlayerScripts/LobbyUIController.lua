-- @ScriptType: LocalScript
-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local UIUtils = require(script:WaitForChild("UIUtils"))
local PlayerMenuBuilder = require(script:WaitForChild("PlayerMenuBuilder"))
local PartyMenuBuilder = require(script:WaitForChild("PartyMenuBuilder"))
local GoalsMenuBuilder = require(script:WaitForChild("GoalsMenuBuilder"))
local ShopMenuBuilder = require(script:WaitForChild("ShopMenuBuilder"))
local LogsMenuBuilder = require(script:WaitForChild("LogsMenuBuilder"))

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LobbyUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.Parent = player:WaitForChild("PlayerGui")

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "CashDisplay"
cashLabel.AnchorPoint = Vector2.new(1, 0)
cashLabel.Size = UDim2.new(0.15, 0, 0.06, 0)
cashLabel.Position = UDim2.new(0.98, 0, 0.02, 0)
cashLabel.Text = "Loading Cash..."
cashLabel.Font = Enum.Font.Oswald
cashLabel.TextScaled = true
cashLabel.BackgroundTransparency = 0.1
cashLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
cashLabel.TextColor3 = Color3.fromRGB(30, 200, 30)
local cashStroke = Instance.new("UIStroke")
cashStroke.Color = Color3.fromRGB(30, 150, 30)
cashStroke.Thickness = 2
cashStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
cashStroke.Parent = cashLabel
UIUtils.addCorner(cashLabel, 6)
cashLabel.Parent = screenGui

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

-- Notification Badge for Goals
local goalsBtn = menuButtons["Goals"]
local notifBadge = Instance.new("Frame")
notifBadge.Name = "NotifBadge"
notifBadge.Size = UDim2.new(0, 18, 0, 18)
notifBadge.Position = UDim2.new(1, -9, 0, -9)
notifBadge.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
UIUtils.addCorner(notifBadge, 9)
notifBadge.Visible = false
notifBadge.Parent = goalsBtn

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, 0, 1, 0)
notifText.BackgroundTransparency = 1
notifText.Text = "!"
notifText.TextColor3 = Color3.new(1, 1, 1)
notifText.Font = Enum.Font.GothamBold
notifText.TextScaled = true
notifText.Parent = notifBadge

menuFrames["Player"] = PlayerMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
menuFrames["Party"] = PartyMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
menuFrames["Goals"] = GoalsMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
menuFrames["Shop"] = ShopMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
menuFrames["Logs"] = LogsMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)

for _, menu in ipairs(menus) do
	menuButtons[menu].MouseButton1Click:Connect(function()
		for k, f in pairs(menuFrames) do
			f.Visible = (k == menu)
		end
		bottomNavContainer.Visible = false
	end)
end

-- Data Syncing Logic
local PlayerDataEvents = ReplicatedStorage:WaitForChild("PlayerDataEvents")

local function updateUIWithData(data)
	cashLabel.Text = "Cash: $" .. (data.Cash or 0)

	if not data.ClaimedAchievements or not data.ClaimedAchievements["Welcome"] then
		notifBadge.Visible = true
	else
		notifBadge.Visible = false
	end
end

task.spawn(function()
	local initialData = PlayerDataEvents.RequestPlayerData:InvokeServer()
	updateUIWithData(initialData)
end)

PlayerDataEvents.SyncPlayerData.OnClientEvent:Connect(function(newData)
	updateUIWithData(newData)
end)