local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

local Window = Fluent:CreateWindow({
    Title = "Aeonic Hub",
    SubTitle = "| Dungeon Heroes ⚔️ | discord.gg/mbyHbxAhhT",
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
    Main = Window:AddTab({ Title = "OP Farm", Icon = "home" }),
    Dungeon = Window:AddTab({ Title = "Lobby", Icon = "play" }),
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

    local Toggle = Tabs.Main:AddToggle("KillAura", {
        Title = "Kill Aura",  
        Default = false 
    })

    local killAuraRunning = false

    Toggle:OnChanged(function(value)
        if value then
            killAuraRunning = true

            task.spawn(function()
                local replicated_storage = cloneref(game:GetService("ReplicatedStorage"))
                local workspace = cloneref(game:GetService("Workspace"))
                local enemies = workspace:FindFirstChild("Mobs")

                local delay = 0.3

                while killAuraRunning do
                    if enemies then
                        local mobs = {}
                        for _, v in ipairs(enemies:GetChildren()) do
                            table.insert(mobs, v)
                        end

                        replicated_storage:WaitForChild("Systems")
                            :WaitForChild("Combat")
                            :WaitForChild("PlayerAttack")
                            :FireServer(mobs)
                    end

                    task.wait(delay)
                end
            end)

        else
            killAuraRunning = false
        end
    end)

    local Toggle2 = Tabs.Main:AddToggle("AutoStart", {Title = "Auto Start", Default = false })

    Toggle2:OnChanged(function()
        while Options.AutoStart.Value do
            game:GetService("ReplicatedStorage"):WaitForChild("Systems"):WaitForChild("Dungeons"):WaitForChild("TriggerStartDungeon"):FireServer()
            wait(0.1)
        end
    end)

    Options.AutoStart:SetValue(false)

    local Toggle4 = Tabs.Main:AddToggle("AutoPlayAgain", {Title = "Play Again", Default = false })

    Toggle4:OnChanged(function()
        while Options.AutoPlayAgain.Value do
            local args = {
                "GoAgain"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Systems"):WaitForChild("Dungeons"):WaitForChild("SetExitChoice"):FireServer(unpack(args))
            wait(0.1)
        end
    end)

    Options.AutoPlayAgain:SetValue(false)
    
    local goto_closest = false
    
    local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
    local user_input_service = cloneref(game:GetService('UserInputService'))
    local local_player = cloneref(game:GetService('Players').LocalPlayer)
    local tween_service = cloneref(game:GetService('TweenService'))
    local run_service = cloneref(game:GetService('RunService'))
    local workspace = cloneref(game:GetService('Workspace'))

    function closest_mob()
        local mob = nil
        local distance = math.huge
        local enemies = workspace:FindFirstChild("Mobs")

        for _, v in next, enemies:GetChildren() do
            if not v:GetAttribute("Owner") and v:GetAttribute("HP") > 0 and v.Name ~= "Side Room Rune Disabled" and v.Name ~= "TargetDummy" then
                local dist = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
                if dist < distance then
                    distance = dist
                    mob = v
                end
            end
        end

        return mob
    end
    local y = 50
    local tweenspeed = 200
    local Toggle3 = Tabs.Main:AddToggle("AutoFarm", {
        Title = "Auto Farm Dungeon",
        Default = false
    })

    Toggle3:OnChanged(function(Value)
        goto_closest = Value
        if Value then
            repeat
                local mob = closest_mob()
                if mob then
                    task.wait(.1)
                    local velocity_connection = run_service.Heartbeat:Connect(function()
                        if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                            local_player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                            local_player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                    local character = local_player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    if hrp and mob then
                        local to = mob:GetPivot().Position
                        local distance = (to - hrp.Position).Magnitude
                        local tween = tween_service:Create(hrp, TweenInfo.new(distance / tweenspeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                            CFrame = CFrame.new(to + Vector3.new(0, y, 0))
                        })
                        tween:Play()
                        tween.Completed:Wait()
                    end
                    if velocity_connection then
                        velocity_connection:Disconnect()
                    end
                end
                task.wait()
            until not goto_closest
        end
    end)

    local tweenspeedslider = Tabs.Main:AddSlider("tweenspeedslider", {
        Title = "Tween Speed",
        Description = "Adjust until your not getting kick",
        Default = 200,
        Min = 20,
        Max = 300,
        Rounding = 0.1,
        Callback = function(Value)
            tweenspeed = Value
        end
    })

    tweenspeedslider:SetValue(200)
    
    local Distance = Tabs.Main:AddSlider("Distance", {
        Title = "Distance Y from mobs",
        Default = 50,
        Min = -100,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            y = Value
        end
    })

    Distance:SetValue(50)
    
    local selected_dungeon = "AstralDungeon"
    local dungeons = Tabs.Dungeon:AddDropdown("dungeons", {
        Title = "Select Dungeon",
        Values = {"AstralDungeon", "CastleDungeon", "CoveDungeon", "DesertDungeon", "ForestDungeon", "JungleDungeon", "MountainDungeon"},
        Multi = false,
        Default = 1,
    })

    dungeons:SetValue("AstralDungeon")

    dungeons:OnChanged(function(Value)
        selected_dungeon = Value
    end)

    local selected_difficulties = 1

    local difficulties = Tabs.Dungeon:AddDropdown("difficulties", {
        Title = "Choose Difficulty",
        Values = {"Normal", "Medium", "Hard", "Insane"},
        Multi = false,
        Default = 1,
    })

    difficulties:SetValue("Normal") -- Set default to a valid option

    difficulties:OnChanged(function(Value)
        if Value == "Normal" then
            selected_difficulties = 1 
        elseif Value == "Medium" then
            selected_difficulties = 2
        elseif Value == "Hard" then
            selected_difficulties = 3
        elseif Value == "Insane" then
            selected_difficulties = 4
        end
    end)

    local selected_player = 1
    local players = Tabs.Dungeon:AddDropdown("players", {
        Title = "Players",
        Values = {"1", "2", "3", "4", "5"},
        Multi = false,
        Default = 1,
    })

    players:SetValue("1")

    players:OnChanged(function(Value)
        if Value == "1" then
            selected_player = 1 
        elseif Value == "2" then
            selected_player = 2
        elseif Value == "3" then
            selected_player = 3
        elseif Value == "4" then
            selected_player = 4
        elseif Value == "5" then
            selected_player = 5
        end
    end)

    Tabs.Dungeon:AddButton({
        Title = "Enter Dungeon",
        Callback = function()
            local args = {
                selected_dungeon,
                selected_difficulties,
                selected_player,
                false
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Systems"):WaitForChild("Parties"):WaitForChild("SetSettings"):FireServer(unpack(args))
        end
    })

    Tabs.Dungeon:AddButton({
        Title = "Return To Lobby",
        Callback = function()
            game:GetService("ReplicatedStorage").Systems.Dungeons.ExitDungeon:FireServer()
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
    --[[
    Tabs.Main:AddParagraph({
        Title = "AFK FARM",
        Content = 'Put script_key = "" above the script and put it in auto execute'
    })
    ]]
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
SaveManager:SetFolder("FluentScriptHub/Dungeon Heroes")



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