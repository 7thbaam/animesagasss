local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

local Window = Fluent:CreateWindow({
    Title = "Aeonic Hub",
    SubTitle = "| Build An Island! 🏝️ | discord.gg/mbyHbxAhhT",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 430),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AeonicHubMini"
gui.ResetOnSpawn = false

local icon = Instance.new("ImageButton")
icon.Name = "AeonicIcon"
icon.Size = UDim2.new(0, 55, 0, 50)
icon.Position = UDim2.new(0, 200, 0, 150)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://121800415377798" -- replace with your real asset ID
icon.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8) -- You can tweak the '8' for more or less rounding
corner.Parent = icon

local dragging, dragInput, dragStart, startPos

icon.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = icon.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

icon.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		icon.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local isMinimized = false
icon.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	Window:Minimize(isMinimized)
end)

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    DevUpd = Window:AddTab({ Title = "About", Icon = "wrench"}),
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "home" }),
    Craft = Window:AddTab({ Title = "Auto Craft", Icon = "wrench" }),
    Collect = Window:AddTab({ Title = "Auto Collect", Icon = "archive" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    AntiAfk = Window:AddTab({ Title = "Anti-Afk", Icon = "clock" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Tabs.DevUpd:AddParagraph({
        Title = "Aeonic Hub",
        Content = "Thank you for using the script! Join the discord if you have problems and suggestions with the script"
    })

    Tabs.DevUpd:AddSection("Discord")
    Tabs.DevUpd:AddButton({
        Title = "Discord",
        Description = "Copy the link to join the discord!",
        Callback = function()
            setclipboard("https://discord.gg/mbyHbxAhhT")
            Fluent:Notify({
                Title = "Notification",
                Content = "Successfully copied to the clipboard!",
                SubContent = "", -- Optional
                Duration = 3 
            })
        end
    })

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ResourcesFolder = ReplicatedStorage:WaitForChild("Storage"):WaitForChild("Resources")

    --[[
    local dropdownValues = {}
    for _, child in ipairs(ResourcesFolder:GetChildren()) do
        table.insert(dropdownValues, child.Name)
    end

    -- Multi-select dropdown
    local resouresmulti = Tabs.Main:AddDropdown("resouresmulti", {
        Title = "Select Resources",
        Values = dropdownValues,
        Multi = true,
        Default = {}, 
    })

    -- Store selected values
    local SelectedValues = {}
    resouresmulti:OnChanged(function(Value)
        SelectedValues = {}
        for resourceName, isSelected in next, Value do
            if isSelected then
                table.insert(SelectedValues, resourceName)
            end
        end
        print("Selected Resources:", table.concat(SelectedValues, ", "))
    end)

    -- Toggle for autofarming selected
    local AutoFarmSelected = Tabs.Main:AddToggle("AutoFarmSelected", {
        Title = "Farm Selected Resources",
        Default = false
    })

    -- Auto farm loop for selected resources only
    AutoFarmSelected:OnChanged(function()
        task.spawn(function()
            while Options.AutoFarmSelected.Value do
                local playerName = game.Players.LocalPlayer.Name
                local plots = workspace:WaitForChild("Plots")
                local myPlot = plots:FindFirstChild(playerName)

                if myPlot and myPlot:FindFirstChild("Resources") then
                    for _, resource in ipairs(myPlot.Resources:GetChildren()) do
                        for _, selectedName in ipairs(SelectedValues) do
                            if resource.Name == selectedName then
                                ReplicatedStorage:WaitForChild("Communication")
                                    :WaitForChild("HitResource")
                                    :FireServer(resource)
                            end
                        end
                    end
                end
                task.wait(0.01)
            end
        end)
    end)

    Options.AutoFarmSelected:SetValue(false)
    ]]

    local AutoFarm = Tabs.Main:AddToggle("AutoFarm", {
        Title = "Instant Farm All",
        Default = false
    })

    AutoFarm:OnChanged(function()
        task.spawn(function()
            while Options.AutoFarm.Value do
                local playerName = game.Players.LocalPlayer.Name
                local plots = workspace:WaitForChild("Plots")
                local myPlot = plots:FindFirstChild(playerName)

                if myPlot and myPlot:FindFirstChild("Resources") then
                    local resources = myPlot.Resources:GetChildren()

                    for _, resource in ipairs(resources) do
                        local hp = resource:GetAttribute("HP")
                        if hp and hp > 0 then
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Communication")
                                :WaitForChild("HitResource")
                                :FireServer(resource)
                        end
                    end
                end
                task.wait(0.1) -- Slight delay to reduce remote spam and ping spikes
            end
        end)
    end)

    Options.AutoFarm:SetValue(false)

    local AutoFarmTree = Tabs.Main:AddToggle("AutoFarmTree", {
        Title = "Auto Farm World Tree",
        Default = false
    })

    AutoFarmTree:OnChanged(function()
        task.spawn(function()
            while Options.AutoFarmTree.Value do
                local globalresources = workspace:FindFirstChild("GlobalResources")

                if globalresources then
                    for _, resource in ipairs(globalresources:GetChildren()) do
                        if resource.Name == "World Tree" then
                            local hp = resource:GetAttribute("HP")
                            if hp and hp > 0 then
                                game:GetService("ReplicatedStorage")
                                    :WaitForChild("Communication")
                                    :WaitForChild("HitResource")
                                    :FireServer(resource)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end)

    Options.AutoFarmTree:SetValue(false)

    local autocollectreward = Tabs.Main:AddToggle("autocollectreward", {Title = "Collect Reward Chest", Default = false })

    autocollectreward:OnChanged(function()
        while Options.autocollectreward.Value do
            local rewardchest = workspace:FindFirstChild("RewardChest")
            if rewardchest then
                local chestkey = rewardchest:GetAttribute("ChestKey")
                local args = {
                    chestkey
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("RewardChestClaimRequest"):FireServer(unpack(args))
            end
            task.wait(0.1)
        end
    end)
    Options.autocollectreward:SetValue(false)

    local autocollectworldtree = Tabs.Main:AddToggle("autocollectworldtree", {Title = "Collect World Tree Seed", Default = false })

    autocollectworldtree:OnChanged(function()
        while Options.autocollectworldtree.Value do
            local worldtreeseed = workspace:FindFirstChild("WorldTreeSeed")
            if worldtreeseed then
                local key = worldtreeseed:GetAttribute("Key")
                local args = {
                    key
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("CollectWorldTree"):FireServer(unpack(args))
            end
            task.wait(0.1)
        end
    end)
    Options.autocollectworldtree:SetValue(false)

    local selldelay = 2
    local autosellall = Tabs.Main:AddToggle("autosellall", {Title = "Auto Sell", Default = false })

    autosellall:OnChanged(function()
        while Options.autosellall.Value do
            local args = {
                true,
                {}
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("SellToMerchant"):FireServer(unpack(args))
            task.wait(selldelay)
        end

    end)

    Options.autosellall:SetValue(false)

    local autoselldelay = Tabs.Main:AddSlider("autoselldelay", {
        Title = "Sell Delay",
        Default = 2,
        Min = 1,
        Max = 60,
        Rounding = 0.1,
        Callback = function(Value)
            selldelay = Value
        end
    })

    autoselldelay:SetValue(2)

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    -- WalkSpeed slider
    local WalkSpeedSlider = Tabs.Main:AddSlider("WalkSpeedSlider", {
        Title = "WalkSpeed",
        Description = "Adjust your walk speed",
        Default = 16,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.WalkSpeed = Value
            end
        end
    })

    local lastWalkSpeed = WalkSpeedSlider.Value

    -- Continuously enforce WalkSpeed
    task.spawn(function()
        while true do
            task.wait(0.1)
            if Character and Character:FindFirstChild("Humanoid") then
                if Character.Humanoid.WalkSpeed ~= lastWalkSpeed then
                    Character.Humanoid.WalkSpeed = lastWalkSpeed
                end
            end
        end
    end)

    -- Update lastWalkSpeed when slider changes
    WalkSpeedSlider:OnChanged(function(Value)
        lastWalkSpeed = Value
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = Value
        end
    end)

    -- Optional: Set initial value
    WalkSpeedSlider:SetValue(16)

    Tabs.Main:AddParagraph({
        Title = "About Auto Expand",
        Content = "I didnt add auto expand cause its much efficient if your the one going to expand"
    })
    local Players = game:GetService("Players")
    local plr = Players.LocalPlayer
    local plot = game:GetService("Workspace"):WaitForChild("Plots"):WaitForChild(plr.Name)
    local craft_delay = 5
    local autocraftall = Tabs.Craft:AddToggle("autocraftall", {Title = "Auto Craft All", Description = "This does not craft furniture or other earning money craft", Default = false })

    autocraftall:OnChanged(function()
        while Options.autocraftall.Value do
            for _, c in pairs(plot:GetDescendants()) do
				if c.Name == "Crafter" then
					local attachment = c:FindFirstChildOfClass("Attachment")
					if attachment then
						game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Craft"):FireServer(attachment)
					end
				end
			end
			task.wait(craft_delay)
        end
    end)
    
    Options.autocraftall:SetValue(false)


    local autocraftalldelay = Tabs.Craft:AddSlider("autocraftalldelay", {
        Title = "Craft All Delay",
        Default = 5,
        Min = 1,
        Max = 60,
        Rounding = 0.1,
        Callback = function(Value)
            craft_delay = Value
        end
    })

    autocraftalldelay:SetValue(3)

    local playerName = game.Players.LocalPlayer.Name

    local plankdelay = 5
    local autocraftplank = Tabs.Craft:AddToggle("autocraftplank", {Title = "Auto Craft Plank", Default = false })
    autocraftplank:OnChanged(function()
        while Options.autocraftplank.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S13"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Craft"):FireServer(unpack(args))
            task.wait(plankdelay)
        end
    end)
    Options.autocraftplank:SetValue(false)

    local autodelayplank = Tabs.Craft:AddSlider("autodelayplank", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            plankdelay = Value
        end
    })
    autodelayplank:SetValue(5)

    local brickdelay = 5
    local autocraftbrick = Tabs.Craft:AddToggle("autocraftbrick", {Title = "Auto Craft Brick", Default = false })
    autocraftbrick:OnChanged(function()
        while Options.autocraftbrick.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S24"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Craft"):FireServer(unpack(args))
            task.wait(brickdelay)
        end
    end)
    Options.autocraftbrick:SetValue(false)

    local autodelaybrick = Tabs.Craft:AddSlider("autodelaybrick", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            brickdelay = Value
        end
    })
    autodelaybrick:SetValue(5)

    local bamboodelay = 5
    local autocraftbamboo = Tabs.Craft:AddToggle("autocraftbamboo", {Title = "Auto Craft Bamboo Plank", Default = false })
    autocraftbamboo:OnChanged(function()
        while Options.autocraftbamboo.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S72"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Craft"):FireServer(unpack(args))
            task.wait(bamboodelay)
        end
    end)
    Options.autocraftbamboo:SetValue(false)

    local autodelaybamboo = Tabs.Craft:AddSlider("autodelaybamboo", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            bamboodelay = Value
        end
    })
    autodelaybamboo:SetValue(5)

    local furnituredelay = 5
    local autocraftfurniture = Tabs.Craft:AddToggle("autocraftfurniture", {Title = "Auto Craft Furniture", Default = false })
    autocraftfurniture:OnChanged(function()
        while Options.autocraftfurniture.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S9"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("DoubleCraft"):FireServer(unpack(args))
            task.wait(furnituredelay)
        end
    end)
    Options.autocraftfurniture:SetValue(false)

    local autodelayfurniture = Tabs.Craft:AddSlider("autodelayfurniture", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            furnituredelay = Value
        end
    })
    autodelayfurniture:SetValue(5)

    local ironbardelay = 5
    local autocraftironbar = Tabs.Craft:AddToggle("autocraftironbar", {Title = "Auto Craft Ironbar", Default = false })
    autocraftironbar:OnChanged(function()
        while Options.autocraftironbar.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S23"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("DoubleCraft"):FireServer(unpack(args))
            task.wait(ironbardelay)
        end
    end)
    Options.autocraftironbar:SetValue(false)

    local autodelayironbar = Tabs.Craft:AddSlider("autodelayironbar", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            ironbardelay = Value
        end
    })
    autodelayironbar:SetValue(5)

    local toolsmithdelay = 5
    local autocrafttoolsmith = Tabs.Craft:AddToggle("autocrafttoolsmith", {Title = "Auto Craft Toolsmith", Default = false })
    autocrafttoolsmith:OnChanged(function()
        while Options.autocrafttoolsmith.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S38"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("DoubleCraft"):FireServer(unpack(args))
            task.wait(toolsmithdelay)
        end
    end)
    Options.autocrafttoolsmith:SetValue(false)

    local autodelaytoolsmith = Tabs.Craft:AddSlider("autodelaytoolsmith", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            toolsmithdelay = Value
        end
    })
    autodelaytoolsmith:SetValue(5)

    local cactusfiberdelay = 5
    local autocraftcactusfiber = Tabs.Craft:AddToggle("autocraftcactusfiber", {Title = "Auto Craft Cactus Fiber", Default = false })
    autocraftcactusfiber:OnChanged(function()
        while Options.autocraftcactusfiber.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S54"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Craft"):FireServer(unpack(args))
            task.wait(cactusfiberdelay)
        end
    end)
    Options.autocraftcactusfiber:SetValue(false)

    local autodelaycactusfiber = Tabs.Craft:AddSlider("autodelaycactusfiber", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            cactusfiberdelay = Value
        end
    })
    autodelaycactusfiber:SetValue(5)

    local magmafurnacedelay = 5
    local autocraftmagmafurnace = Tabs.Craft:AddToggle("autocraftmagmafurnace", {Title = "Auto Craft Magma Furnace", Default = false })
    autocraftmagmafurnace:OnChanged(function()
        while Options.autocraftmagmafurnace.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S106"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("DoubleCraft"):FireServer(unpack(args))
            task.wait(magmafurnacedelay)
        end
    end)
    Options.autocraftmagmafurnace:SetValue(false)

    local autodelaymagmafurnace = Tabs.Craft:AddSlider("autodelaymagmafurnace", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            magmafurnacedelay = Value
        end
    })
    autodelaymagmafurnace:SetValue(5)

    local haydelay = 5
    local autocrafthay = Tabs.Craft:AddToggle("autocrafthay", {Title = "Auto Craft Hay Baler", Default = false })
    autocrafthay:OnChanged(function()
        while Options.autocrafthay.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S178"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Craft"):FireServer(unpack(args))
            task.wait(haydelay)
        end
    end)
    Options.autocrafthay:SetValue(false)

    local autodelayhay = Tabs.Craft:AddSlider("autodelayhay", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            haydelay = Value
        end
    })
    autodelayhay:SetValue(5)

    local magmasawmilldelay = 5
    local autocraftmagmasawmill = Tabs.Craft:AddToggle("autocraftmagmasawmill", {Title = "Auto Craft Magma Sawmill", Default = false })
    autocraftmagmasawmill:OnChanged(function()
        while Options.autocraftmagmasawmill.Value do
            local args = {
                workspace:WaitForChild("Plots"):WaitForChild(playerName):WaitForChild("Land"):WaitForChild("S108"):WaitForChild("Crafter"):WaitForChild("Attachment")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Craft"):FireServer(unpack(args))
            task.wait(magmasawmilldelay)
        end
    end)
    Options.autocraftmagmasawmill:SetValue(false)

    local autodelaymagmasawmill = Tabs.Craft:AddSlider("autodelaymagmasawmill", {
        Title = "Craft Delay",
        Default = 5,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            magmasawmilldelay = Value
        end
    })
    autodelaymagmasawmill:SetValue(5)

    local Toggle4 = Tabs.AntiAfk:AddToggle("AntiAfk", {
        Title = "Anti-Afk", 
        Description = "This will prevent you from being kicked when AFK", 
        Default = false 
    })
    
    Toggle4:OnChanged(function()
        task.spawn(function()
            while Options.AntiAfk.Value do
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                task.wait(10)
            end
        end)
    end)
    Options.AntiAfk:SetValue(false)
    local land = plot:FindFirstChild("Land")
    local autogivegoldmine = Tabs.Collect:AddToggle("autogivegoldmine", {Title = "Auto Give Coal Crate", Default = false })

    autogivegoldmine:OnChanged(function()
        while Options.autogivegoldmine.Value do
			for _, mine in pairs(land:GetDescendants()) do
				if mine:IsA("Model") and mine.Name == "GoldMineModel" then
					game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Goldmine"):FireServer(mine.Parent.Name, 1)
				end
			end
			task.wait(1)
        end
    end)
    
    Options.autogivegoldmine:SetValue(false)

    local autocollectgoldmine = Tabs.Collect:AddToggle("autocollectgoldmine", {Title = "Auto Collect Gold Mine", Default = false })

    autocollectgoldmine:OnChanged(function()
        while Options.autocollectgoldmine.Value do
			for _, mine in pairs(land:GetDescendants()) do
				if mine:IsA("Model") and mine.Name == "GoldMineModel" then
					game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Goldmine"):FireServer(mine.Parent.Name, 2)
				end
			end
			task.wait(1)
        end
    end)
    Options.autocollectgoldmine:SetValue(false)

    local autoharvest = Tabs.Collect:AddToggle("autoharvest", {Title = "Auto Harvest Crops", Default = false })

    autoharvest:OnChanged(function()
        while Options.autoharvest.Value do
			for _, crop in pairs(plot:FindFirstChild("Plants"):GetChildren()) do
				game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Harvest"):FireServer(crop.Name)
			end
			task.wait(1)
        end
    end)
    
    Options.autoharvest:SetValue(false)

    local autohive = Tabs.Collect:AddToggle("autohive", {Title = "Auto Collect Hive", Default = false })

    autohive:OnChanged(function()
        while Options.autohive.Value do
            for _, spot in ipairs(land:GetDescendants()) do
                if spot:IsA("Model") and spot.Name:match("Spot") then
                    game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Hive"):FireServer(spot.Parent.Name, spot.Name, 2)
                end
            end
            task.wait(1)
        end
    end)
    
    Options.autohive:SetValue(false)

    local autoaddbales = Tabs.Collect:AddToggle("autoaddbales", {Title = "Auto Add Bales", Default = false })

    autoaddbales:OnChanged(function()
        while Options.autoaddbales.Value do
			for _, mine in pairs(land:GetDescendants()) do
				if mine:IsA("Model") and mine.Name == "AnimalPen" then
                    game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Animals"):WaitForChild("AddHay"):FireServer(mine.Parent.Name)
				end
			end
            task.wait(1)
        end
    end)
    
    Options.autoaddbales:SetValue(false)
    

    local items = {}
    for _, item in ipairs(plr.PlayerGui.Main.Menus.Merchant.Inner.ScrollingFrame.Hold:GetChildren()) do
        if item:IsA("Frame") and item.Name ~= "Example" then
            table.insert(items, item.Name)
        end
    end

    -- Global variable to store selected items
    getgenv().selectedItems = {}

    local itemsmulti = Tabs.Shop:AddDropdown("itemsmulti", {
        Title = "Select Items",
        Values = items,
        Multi = true,
        Default = {},
    })

    -- Update selected items
    itemsmulti:OnChanged(function(value)
        local values = {}
        for itemName, isSelected in pairs(value) do
            if isSelected then
                table.insert(values, itemName)
            end
        end
        selectedItems = values
    end)

    -- Auto Buy Toggle
    local autobuy = Tabs.Shop:AddToggle("autobuy", { Title = "Auto Buy", Default = false })

    autobuy:OnChanged(function()
        task.spawn(function()
            while Options.autobuy.Value do
                for _, itemName in ipairs(selectedItems) do
                    local args = { itemName, false }
                    game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("BuyFromMerchant"):FireServer(unpack(args))
                    task.wait(0.25) -- slight delay per item
                end
                task.wait(1) -- main loop delay
            end
        end)
    end)

    Options.autobuy:SetValue(false)
end  

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)

SaveManager:IgnoreThemeSettings()
-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/Build an Island")



InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Aeonic Hub",
    Content = "The script has been loaded.",
    Duration = 3
})
task.wait(3)
Fluent:Notify({
    Title = "Aeonic Hub",
    Content = "Join the discord for more updates",
    Duration = 8
})
-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
