-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local ShopMenuBuilder = {}

function ShopMenuBuilder.build(screenGui, UIUtils, bottomNavContainer)
	local shopMenuBG, shopContainer, shopList = UIUtils.createStandardPopup("Shop", screenGui, bottomNavContainer)
	UIUtils.addListLayout(shopList, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)
	UIUtils.addPadding(shopList, 10)

	local shopBox = Instance.new("Frame")
	shopBox.Size = UDim2.new(1, 0, 0, 80)
	shopBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	UIUtils.addCorner(shopBox, 6)

	local sTitle = Instance.new("TextLabel")
	sTitle.Size = UDim2.new(0.6, 0, 0.35, 0)
	sTitle.Position = UDim2.new(0.05, 0, 0.1, 0)
	sTitle.BackgroundTransparency = 1
	sTitle.Text = "Template Item"
	sTitle.TextColor3 = Color3.fromRGB(218, 165, 32)
	sTitle.Font = Enum.Font.Oswald
	sTitle.TextScaled = true
	sTitle.TextXAlignment = Enum.TextXAlignment.Left
	sTitle.Parent = shopBox

	local sDesc = Instance.new("TextLabel")
	sDesc.Size = UDim2.new(0.6, 0, 0.4, 0)
	sDesc.Position = UDim2.new(0.05, 0, 0.5, 0)
	sDesc.BackgroundTransparency = 1
	sDesc.Text = "An epic item that does something cool."
	sDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
	sDesc.Font = Enum.Font.Gotham
	sDesc.TextScaled = true
	sDesc.TextXAlignment = Enum.TextXAlignment.Left
	sDesc.TextYAlignment = Enum.TextYAlignment.Top
	sDesc.Parent = shopBox

	local sBuyBtn = UIUtils.createButton("BuyBtn", "Buy", shopBox)
	sBuyBtn.Size = UDim2.new(0.25, 0, 0.6, 0)
	sBuyBtn.Position = UDim2.new(0.7, 0, 0.2, 0)
	sBuyBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)

	local TEMPLATE_PRODUCT_ID = 0 -- Hooked up to a blank ID as requested

	sBuyBtn.MouseButton1Click:Connect(function()
		if TEMPLATE_PRODUCT_ID ~= 0 then
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, TEMPLATE_PRODUCT_ID)
		else
			warn("Purchase failed: Product ID is 0 (Blank ID)")
		end
	end)

	shopBox.Parent = shopList

	return shopMenuBG
end

return ShopMenuBuilder