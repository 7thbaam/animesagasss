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
    local dropdownValues = {}
    for _, child in ipairs(ResourcesFolder:GetChildren()) do
        table.insert(dropdownValues, child.Name)
    end

    local resouresmulti = Tabs.Main:AddDropdown("resouresmulti", {
        Title = "Select Resources",
        Values = dropdownValues,
        Multi = true,
        Default = {}, 
    })

    resouresmulti:OnChanged(function(Value)
        Values = {}
        for Value, State in next, Value do
            table.insert(Values, Value)
        end
        print("Mutlidropdown changed:", table.concat(Values, ", "))
    end)

    local AutoFarmSelected = Tabs.Main:AddToggle("AutoFarmSelected", {Title = "Farm Selected Resources", Default = false })
    local function closest_selected_resource(resources)
        local character = game.Players.LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

        local root = character.HumanoidRootPart
        local closest = nil
        local shortestDistance = math.huge

        for _, resource in pairs(resources) do
            if resource:GetAttribute("HP") and resource:GetAttribute("HP") > 0 then
                for _, v in ipairs(Values) do
                    if resource.Name == v then
                        local resourceRoot = resource:FindFirstChild("Root")
                        if resourceRoot and resourceRoot:IsA("BasePart") then
                            local distance = (root.Position - resourceRoot.Position).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closest = resource
                            end
                        end
                        break
                    end
                end
            end
        end

        return closest
    end
    AutoFarmSelected:OnChanged(function()
        task.spawn(function()
            while Options.AutoFarmSelected.Value do
                local playerName = game.Players.LocalPlayer.Name
                local plots = workspace:WaitForChild("Plots")
                local myPlot = plots:FindFirstChild(playerName)

                if myPlot and myPlot:FindFirstChild("Resources") then
                    local resource = closest_selected_resource(myPlot.Resources:GetChildren())
                    while resource and resource:GetAttribute("HP") and resource:GetAttribute("HP") > 0 do
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Communication")
                            :WaitForChild("HitResource")
                            :FireServer(resource)
                        task.wait(0.1)
                    end
                end

                task.wait(0.1)
            end
        end)
    end)
    Options.AutoFarmSelected:SetValue(false)

    local AutoFarm = Tabs.Main:AddToggle("AutoFarm", {Title = "Farm All", Description = "This will farm the closest resources to you", Default = false })
    local function closest_resource(resources)
        local character = game.Players.LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

        local root = character.HumanoidRootPart
        local closest = nil
        local shortestDistance = math.huge

        for _, resource in pairs(resources) do
            if resource:GetAttribute("HP") and resource:GetAttribute("HP") > 0 then
                local resourceRoot = resource:FindFirstChild("Root")
                if resourceRoot and resourceRoot:IsA("BasePart") then
                    local distance = (root.Position - resourceRoot.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = resource
                    end
                end
            end
        end

        return closest
    end
    AutoFarm:OnChanged(function()
        task.spawn(function()
            while Options.AutoFarm.Value do
                local playerName = game.Players.LocalPlayer.Name
                local plots = workspace:WaitForChild("Plots")
                local myPlot = plots:FindFirstChild(playerName)

                if myPlot and myPlot:FindFirstChild("Resources") then
                    local resource = closest_resource(myPlot.Resources:GetChildren())
                    while resource and resource:GetAttribute("HP") and resource:GetAttribute("HP") > 0 do
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Communication")
                            :WaitForChild("HitResource")
                            :FireServer(resource)
                        task.wait(0.1)
                    end
                end

                task.wait(0.1)
            end
        end)
    end)
    Options.AutoFarm:SetValue(false)

    local selldelay = 2
    local autosellall = Tabs.Main:AddToggle("autosellall", {Title = "Auto Sell All", Default = false })

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
        Title = "Auto Sell Delay",
        Default = 2,
        Min = 1,
        Max = 60,
        Rounding = 0.1,
        Callback = function(Value)
            selldelay = Value
        end
    })

    autoselldelay:SetValue(2)

    Tabs.Main:AddParagraph({
        Title = "About Auto Expand",
        Content = "I didnt add auto expand cause its much efficient if your the one going to expand"
    })

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

    local autogivegoldmine = Tabs.Collect:AddToggle("autogivegoldmine", {Title = "Auto Give Coal Crate", Default = false })

    autogivegoldmine:OnChanged(function()
        while Options.autogivegoldmine.Value do
            local args = {
                "S8",
                1
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Goldmine"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
    
    Options.autogivegoldmine:SetValue(false)

    local autocollectgoldmine = Tabs.Collect:AddToggle("autocollectgoldmine", {Title = "Auto Collect Gold Mine", Default = false })

    autocollectgoldmine:OnChanged(function()
        while Options.autocollectgoldmine.Value do
            local args = {
                "S8",
                2
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Communication"):WaitForChild("Goldmine"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
    Options.autocollectgoldmine:SetValue(false)



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