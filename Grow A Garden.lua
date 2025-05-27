local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

local Window = Fluent:CreateWindow({
    Aeonic Hub
    Title = "Aeonic Hub",
    SubTitle = "| [🌙] Grow a Garden 🍄 | discord.gg/mbyHbxAhhT",
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
    Main = Window:AddTab({ Title = "Farm", Icon = "home" }),
    Sell = Window:AddTab({ Title = "Sell", Icon = "dollar-sign" }),
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
    local autoPlantDelay = 0.1 -- Set a default value

    local players = cloneref(game:GetService('Players'))
    local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
    local local_player = players.LocalPlayer
    local Toggle6 = Tabs.Main:AddToggle("AutoPlant", {Title = "Auto Plant", Description = "This will plant the seed in your current location", Default = false })

    Toggle6:OnChanged(function()
        while Options.AutoPlant.Value do
            local tool = local_player.Character:FindFirstChildOfClass("Tool")
            if tool and tool:GetAttribute("ItemName") then
                replicated_storage:WaitForChild("GameEvents"):WaitForChild("Plant_RE"):FireServer(
                    local_player.Character:GetPivot().Position,
                    tool:GetAttribute("ItemName")
                )
            else
                Fluent:Notify({
                    Title = "Aeonic Hub",
                    Content = "You must first equip the seed",
                    Duration = 3
                })
            end
            task.wait(autoPlantDelay)
        end
    end)


    Options.AutoPlant:SetValue(false)

    local Slider = Tabs.Main:AddSlider("AutoPlantDelay", {
        Title = "Auto Plant Delay",
        Default = 0.1,
        Min = 0.1,
        Max = 10,
        Rounding = 1,
        Step = 0.1,
        Callback = function(Value)
            autoPlantDelay = Value
        end
    })

    Slider:SetValue(0.1)


    -- Auto Collect Plants
    local Toggle = Tabs.Main:AddToggle("AutoCollectPlants", {Title = "Auto Collect Plants", Default = false })
    Toggle:OnChanged(function()
        task.spawn(function()
            while Options.AutoCollectPlants.Value do
                local farm = game.Workspace.Farm
                local player = game.Players.LocalPlayer
                for _, myfarm in pairs(farm:GetChildren()) do
                    local owner = myfarm.Important.Data.Owner
                    if player.Name == owner.Value then
                        local plants = myfarm.Important.Plants_Physical
                        for _, plant in pairs(plants:GetChildren()) do
                            for _, number in pairs(plant:GetChildren()) do
                                local proxi = number:FindFirstChild("ProximityPrompt")
                                if proxi then
                                    fireproximityprompt(proxi)
                                end
                            end
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end)
    Options.AutoCollectPlants:SetValue(false)


    -- Auto Collect Fruits
    local Toggle3 = Tabs.Main:AddToggle("AutoCollectFruits", {Title = "Auto Collect Fruits", Default = false })
    Toggle3:OnChanged(function()
        task.spawn(function()
            while Options.AutoCollectFruits.Value do
                local farm = game.Workspace.Farm
                local player = game.Players.LocalPlayer
                for _, myfarm in pairs(farm:GetChildren()) do
                    local owner = myfarm.Important.Data.Owner
                    if player.Name == owner.Value then
                        local plants = myfarm.Important.Plants_Physical
                        for _, plant in pairs(plants:GetChildren()) do
                            local fruits = plant:FindFirstChild("Fruits")
                            if fruits then
                                for _, fruit in pairs(fruits:GetChildren()) do
                                    for _, number in pairs(fruit:GetChildren()) do
                                        local proxi = number:FindFirstChild("ProximityPrompt")
                                        if proxi then
                                            fireproximityprompt(proxi)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end)
    Options.AutoCollectFruits:SetValue(false)

    local sellDelay = 0.1
    local Toggle2 = Tabs.Sell:AddToggle("AutoSellInventory", {Title = "Auto Sell Inventory", Default = false })

    Toggle2:OnChanged(function()
        while Options.AutoSellInventory.Value do
            local player = game.Players.LocalPlayer
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local first_pos = hrp.CFrame.Position
            hrp.CFrame = CFrame.new(61.57798767089844, 2.999999761581421, 0.4267970621585846)
            task.wait(0.5)
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
            hrp.CFrame = CFrame.new(first_pos)
            task.wait(sellDelay)
        end
    end)
    
    Options.AutoSellInventory:SetValue(false)

    local AutoSellDelay = Tabs.Sell:AddSlider("AutoSellDelay", {
        Title = "Auto Sell Delay",
        Default = 0.1,
        Min = 0.1,
        Max = 60,
        Rounding = 1,
        Step = 0.1,
        Callback = function(Value)
            sellDelay = Value
        end
    })

    AutoSellDelay:SetValue(0.1)

    -- Auto Sell Inventory
    Tabs.Sell:AddButton({
        Title = "Sell Inventory",
        Callback = function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local first_pos = hrp.CFrame.Position
            hrp.CFrame = CFrame.new(61.57798767089844, 2.999999761581421, 0.4267970621585846)
            task.wait(0.5)
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
            hrp.CFrame = CFrame.new(first_pos)
        end
    })

    -- Auto Sell Item
    Tabs.Sell:AddButton({
        Title = "Sell Item In Hand",
        Callback = function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local first_pos = hrp.CFrame.Position
            hrp.CFrame = CFrame.new(61.57798767089844, 2.999999761581421, 0.4267970621585846)
            task.wait(0.5)
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Item"):FireServer()
            hrp.CFrame = CFrame.new(first_pos)
        end
    })

    Tabs.Shop:AddSection("Seed Shop")
    local selected_seeds = {}
    local seeds = {}
    local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
    local seed_shop = require(replicated_storage.Data.SeedData)
    for i, v in next, seed_shop do
        if v.StockChance > 0 then -- Can also use: if v.DisplayInShop then
            table.insert(seeds, i)
        end
    end
    local AutoBuySeed = Tabs.Shop:AddToggle("AutoBuySeed", {Title = "Auto Buy Seeds", Default = false })

    AutoBuySeed:OnChanged(function()
        while Options.AutoBuySeed.Value do
            for i, _ in next, selected_seeds do
                replicated_storage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(i)
            end
            task.wait(0.1)
        end
    end)
    
    Options.AutoBuySeed:SetValue(false)

    local select_seed = Tabs.Shop:AddDropdown("select_seed", {
        Title = "Select Seeds",
        Values = seeds,
        Multi = true,
        Default = selected_seeds,
    })

    select_seed:SetValue(selected_seeds)

    select_seed:OnChanged(function(Value)
        selected_seeds = Value
    end)

    Tabs.Shop:AddButton({
        Title = "Open Close Seed Shop",
        Callback = function()
            if game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop.Enabled == false then
                game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop.Enabled = true
            elseif game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop.Enabled == true then
                game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop.Enabled = false
            end
        end
    })
    
    Tabs.Shop:AddSection("Gear Shop")

    local selected_gears = {}
    local gears = {}
    local gear_shop = require(replicated_storage.Data.GearData)
    for _, v in next, gear_shop do
        if v.StockChance > 0 then
            table.insert(gears, v.GearName)
        end
    end
    local autobuygears = Tabs.Shop:AddToggle("autobuygears", {Title = "Auto Buy Gears", Default = false })
    autobuygears:OnChanged(function()
        while Options.autobuygears.Value do
            for i, _ in next, selected_gears do
                replicated_storage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(i)
            end
            task.wait(0.1)
        end
    end)
    
    Options.autobuygears:SetValue(false)

    local selected_gear = Tabs.Shop:AddDropdown("selected_gear", {
        Title = "Select Gears",
        Values = gears,
        Multi = true,
        Default = selected_gears,
    })

    selected_gear:SetValue(selected_gears)

    selected_gear:OnChanged(function(Value)
        selected_gears = Value
    end)

    Tabs.Shop:AddButton({
        Title = "Open Close Gear Shop",
        Callback = function()
            if game:GetService("Players").LocalPlayer.PlayerGui.Gear_Shop.Enabled == false then
                game:GetService("Players").LocalPlayer.PlayerGui.Gear_Shop.Enabled = true
            elseif game:GetService("Players").LocalPlayer.PlayerGui.Gear_Shop.Enabled == true then
                game:GetService("Players").LocalPlayer.PlayerGui.Gear_Shop.Enabled = false
            end
        end
    })

    Tabs.Shop:AddButton({
        Title = "Show Daily Quests",
        Callback = function()
            if game:GetService("Players").LocalPlayer.PlayerGui.DailyQuests_UI.Enabled == false then
                game:GetService("Players").LocalPlayer.PlayerGui.DailyQuests_UI.Enabled = true
            elseif game:GetService("Players").LocalPlayer.PlayerGui.DailyQuests_UI.Enabled == true then
                game:GetService("Players").LocalPlayer.PlayerGui.DailyQuests_UI.Enabled = false
            end
        end
    })

    -- Auto Anti-Afk
    local Toggle4 = Tabs.AntiAfk:AddToggle("AntiAfk", {
        Title = "Anti-Afk", 
        Description = "This will prevent you from being kicked when AFK", 
        Default = false 
    })

    Toggle4:OnChanged(function()
        task.spawn(function()
            while Options.AntiAfk.Value do
                -- Simulate player activity to prevent AFK kick
                local VirtualUser = game:GetService("VirtualUser")
                
                -- Move the mouse slightly to simulate activity
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                
                print("Anti-AFK activated")
                task.wait(10)
            end
        end)
    end)

    Options.AntiAfk:SetValue(false)



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
SaveManager:SetFolder("FluentScriptHub/Grow A Pond")



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
    Content = "Join the discord for more updates and keyless scripts",
    Duration = 8
})
-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()