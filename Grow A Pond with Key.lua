    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

    local Window = Fluent:CreateWindow({
        Title = "Grow a Fish Pond 🐠",
        SubTitle = "|| Aeonic Hub || discord.gg/mbyHbxAhhT",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
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
    icon.Size = UDim2.new(0, 60, 0, 60)
    icon.Position = UDim2.new(0, 200, 0, 150)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://97537080663796" -- replace with your real asset ID
    icon.Parent = gui

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

        -- Auto Sell
        local Toggle = Tabs.Main:AddToggle("AutoSell", {Title = "Auto Sell All", Description = "This will sell all your fish", Default = false })
        Toggle:OnChanged(function()
            task.spawn(function()
                while Options.AutoSell.Value do
                    local args = {
                        "ALL"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RBXUtil"):WaitForChild("Net"):WaitForChild("RE/Sell Fish"):FireServer(unpack(args))
                    
                    task.wait(5)
                end
            end)
        end)
        Options.AutoSell:SetValue(false)



        -- Auto Drop Fish
        local Toggle2 = Tabs.Main:AddToggle("AutoDrop", {Title = "Auto Drop Fish", Description = "You must equip the fish you want to drop", Default = false })
        Toggle2:OnChanged(function()
            task.spawn(function()
                while Options.AutoDrop.Value do
                    local plots = game.Workspace.Plots
                    local player = game.Players.LocalPlayer
                    local hrp = player.Character.HumanoidRootPart
                    for _, plot in pairs(plots:GetChildren()) do
                        if plot:FindFirstChild("PlotConfig") and plot.PlotConfig:FindFirstChild("Owner") and plot.PlotConfig.Owner.Value == player then
                            local body_pos = plot.Pond.Assest.Body.WorldPivot.Position
                            hrp.CFrame = CFrame.new(body_pos)
                        end
                    end
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RBXUtil"):WaitForChild("Net"):WaitForChild("URE/Drop Fish"):FireServer()
                    task.wait(0.1)
                end
            end)
        end)
        Options.AutoDrop:SetValue(false)

        -- Auto Collect Fish
        local Toggle3 = Tabs.Main:AddToggle("AutoCollect", {Title = "Auto Collect Fish", Description = "This auto collect fish in your pond", Default = false })
        Toggle3:OnChanged(function()
            task.spawn(function()
                while Options.AutoCollect.Value do
                    local plots = game.Workspace.Plots
                    local player = game.Players.LocalPlayer
                    local hrp = player.Character.HumanoidRootPart
                    for _, plot in pairs(plots:GetChildren()) do
                        if plot:FindFirstChild("PlotConfig") and plot.PlotConfig:FindFirstChild("Owner") and plot.PlotConfig.Owner.Value == player then
                            local body_pos = plot.Pond.Assest.Coral.WorldPivot.Position
                            hrp.CFrame = CFrame.new(body_pos)
                            task.wait(1)
                            for _, fish in pairs(plot.Scripted.Fishes:GetChildren()) do
                                if fish:FindFirstChild("FishGrabPrompt") then
                                    fireproximityprompt(fish.FishGrabPrompt)
                                end
                            end
                        end
                    end 
                    task.wait(1)  
                end
            end)
        end)
        Options.AutoCollect:SetValue(false)
        
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
