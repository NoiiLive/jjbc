-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local updateHairEvent = ReplicatedStorage:WaitForChild("UpdateHairEvent")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LobbyUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsDisplay"
coinsLabel.Size = UDim2.new(0, 200, 0, 50)
coinsLabel.Position = UDim2.new(1, -210, 0, 10)
coinsLabel.Text = "Coins: 0"
coinsLabel.TextScaled = true
coinsLabel.BackgroundTransparency = 0.5
coinsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
coinsLabel.TextColor3 = Color3.new(1, 1, 1)
coinsLabel.Parent = screenGui

local bottomNav = Instance.new("Frame")
bottomNav.Name = "BottomNav"
bottomNav.Size = UDim2.new(1, 0, 0, 80)
bottomNav.Position = UDim2.new(0, 0, 1, -80)
bottomNav.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
bottomNav.Parent = screenGui

local menus = {"Party", "Player", "Goals", "Shop", "Logs"}

for i, menu in ipairs(menus) do
	local btn = Instance.new("TextButton")
	btn.Name = menu .. "Button"
	btn.Size = UDim2.new(0.2, 0, 1, 0)
	btn.Position = UDim2.new((i - 1) * 0.2, 0, 0, 0)
	btn.Text = menu
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = bottomNav
end

local playerMenu = Instance.new("Frame")
playerMenu.Name = "PlayerMenu"
playerMenu.Size = UDim2.new(1, 0, 1, 0)
playerMenu.Position = UDim2.new(0, 0, 0, 0)
playerMenu.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
playerMenu.Visible = false
playerMenu.Parent = screenGui

local customizationMenu = Instance.new("Frame")
customizationMenu.Name = "CustomizationMenu"
customizationMenu.Size = UDim2.new(0.8, 0, 0.8, 0)
customizationMenu.Position = UDim2.new(0.1, 0, 0.1, 0)
customizationMenu.BackgroundTransparency = 1
customizationMenu.Parent = playerMenu

local rightSide = Instance.new("Frame")
rightSide.Name = "RightSide"
rightSide.Size = UDim2.new(0.4, 0, 1, 0)
rightSide.Position = UDim2.new(0.6, 0, 0, 0)
rightSide.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
rightSide.Parent = customizationMenu

local hairInputs = {}

for i = 1, 5 do
	local hairInput = Instance.new("TextBox")
	hairInput.Name = "HairID" .. i
	hairInput.Size = UDim2.new(0.8, 0, 0.08, 0)
	hairInput.Position = UDim2.new(0.1, 0, 0.1 * i, 0)
	hairInput.PlaceholderText = "Enter Hair ID " .. i
	hairInput.TextScaled = true
	hairInput.Parent = rightSide
	table.insert(hairInputs, hairInput)
end

local resetHair = Instance.new("TextButton")
resetHair.Name = "ResetHair"
resetHair.Size = UDim2.new(0.8, 0, 0.1, 0)
resetHair.Position = UDim2.new(0.1, 0, 0.7, 0)
resetHair.Text = "Reset to Default Hair"
resetHair.TextScaled = true
resetHair.Parent = rightSide

local applyHair = Instance.new("TextButton")
applyHair.Name = "ApplyHair"
applyHair.Size = UDim2.new(0.8, 0, 0.1, 0)
applyHair.Position = UDim2.new(0.1, 0, 0.85, 0)
applyHair.Text = "Apply Hair IDs"
applyHair.TextScaled = true
applyHair.Parent = rightSide

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "FinishButton"
closeBtn.Size = UDim2.new(0.2, 0, 0.08, 0)
closeBtn.Position = UDim2.new(0.4, 0, 0.9, 0)
closeBtn.Text = "Finish"
closeBtn.TextScaled = true
closeBtn.Parent = playerMenu

local playerBtn = bottomNav:WaitForChild("PlayerButton")

playerBtn.MouseButton1Click:Connect(function()
	playerMenu.Visible = true
	bottomNav.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
	playerMenu.Visible = false
	bottomNav.Visible = true
end)

applyHair.MouseButton1Click:Connect(function()
	local ids = {}
	for _, input in ipairs(hairInputs) do
		if input.Text ~= "" then
			table.insert(ids, input.Text)
		end
	end
	updateHairEvent:FireServer(ids)
end)

resetHair.MouseButton1Click:Connect(function()
	for _, input in ipairs(hairInputs) do
		input.Text = ""
	end
	updateHairEvent:FireServer({})
end)