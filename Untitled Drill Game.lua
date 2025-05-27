local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

local Window = Fluent:CreateWindow({
    Title = "Aeonic Hub",
    SubTitle = "| [🍀1.5X LUCK] untitled drill game ⚙️ | discord.gg/mbyHbxAhhT",
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
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Craft = Window:AddTab({ Title = "Crafting", Icon = "axe" }),
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

    -- Auto Roll
    local Toggle = Tabs.Main:AddToggle("AutoDrill", {Title = "Instant Drill", Description = "This will instant drill ores", Default = false })
    Toggle:OnChanged(function()
        task.spawn(function()
            while Options.AutoDrill.Value do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("RequestRandomOre"):FireServer()
                task.wait(0.1)
            end
        end)
    end)
    Options.AutoDrill:SetValue(false)



    -- Auto Collect All Drills
    local Toggle3 = Tabs.Main:AddToggle("AutoCollect", {
        Title = "Auto Collect Drills",
        Description = "This will collect the ores in all drills",
        Default = false
    })

    Toggle3:OnChanged(function()
        task.spawn(function()
            while Options.AutoCollect.Value do
                local player = game.Players.LocalPlayer
                local plots = game.Workspace:WaitForChild("Plots")

                for _, myPlot in pairs(plots:GetChildren()) do
                    if myPlot:FindFirstChild("Owner") and myPlot.Owner.Value == player then
                        local drills = myPlot:FindFirstChild("Drills")
                        if drills then
                            for _, drill in pairs(drills:GetChildren()) do
                                game:GetService("ReplicatedStorage")
                                    :WaitForChild("Packages")
                                    :WaitForChild("Knit")
                                    :WaitForChild("Services")
                                    :WaitForChild("PlotService")
                                    :WaitForChild("RE")
                                    :WaitForChild("CollectDrill")
                                    :FireServer(drill)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end)

    Options.AutoCollect:SetValue(false)

    Tabs.Main:AddSection("Sell")
    Tabs.Main:AddButton({
        Title = "Sell All Items",
        Description = "This will sell all your items",
        Callback = function()
            local player = game.Players.LocalPlayer
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local first_pos = hrp.CFrame.Position
            hrp.CFrame = CFrame.new(-377.6177978515625, 92.03533935546875, 283.3897705078125)
            task.wait(0.5)
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("SellAll"):FireServer()
            hrp.CFrame = CFrame.new(first_pos)
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

    Tabs.Main:AddSection("Rebirth")
    -- Auto Rebirth
    local Toggle5 = Tabs.Main:AddToggle("AutoRebirth", {Title = "Auto Rebirth", Description = "This will auto rebirth if you meet the requirments", Default = false })
    Toggle5:OnChanged(function()
        task.spawn(function()
            while Options.AutoRebirth.Value do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("RebirthService"):WaitForChild("RE"):WaitForChild("RebirthRequest"):FireServer()
                task.wait(2)
            end
        end)
    end)
    Options.AutoRebirth:SetValue(false)

    local selectedItem
    local Crafting = Tabs.Craft:AddDropdown("Crafting", {
        Title = "Select Item",
        Description = "Select the item that you want to craft",
        Values = {"Night Totem", "Rain Totem", "Twinspire Drill", "Ionized Plasma Drill", 
        "Overcharged Surge Drill", "Void Chamber", "Scorching Nuclear Drill", "Titanforge Drill", 
        "Reaper Drill", "Voidbound Singularity Drill", "Aetherborn Drill"},
        Multi = false,
        Default = 1,
    })

    Crafting:SetValue("Night Totem")

    Crafting:OnChanged(function(Value)
        selectedItem = Value
    end)

    Tabs.Craft:AddButton({
        Title = "Craft Item",
        Description = "You need to meet the requirements to craft",
        Callback = function()
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RF"):WaitForChild("CraftItem"):InvokeServer(selectedItem)
        end
    })

    Tabs.Shop:AddButton({
        Title = "Drills Shop",
        Description = "You can open and close the ui by clicking this button",
        Callback = function()
            local player = game:GetService("Players").LocalPlayer
            local drillUI = player:WaitForChild("PlayerGui")
                :WaitForChild("Menu")
                :WaitForChild("CanvasGroup")
                :WaitForChild("Buy") -- double-check exact spelling here

            drillUI.Visible = not drillUI.Visible
        end
    })

    Tabs.Shop:AddButton({ 
        Title = "Handdrills Shop",
        Description = "You can open and close the ui by clicking this button",
        Callback = function()
            local player = game:GetService("Players").LocalPlayer
            local handdrillUI = player:WaitForChild("PlayerGui")
                :WaitForChild("Menu")
                :WaitForChild("CanvasGroup")
                :WaitForChild("HandDrills") -- double-check exact spelling here

            handdrillUI.Visible = not handdrillUI.Visible
        end
    })


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
SaveManager:SetFolder("FluentScriptHub/Untitled Drill Game")



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