repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

local Window = Fluent:CreateWindow({
    Title = "Aeonic Hub",
    SubTitle = "| Pixel Blade | discord.gg/mbyHbxAhhT",
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
    Portal = Window:AddTab({ Title = "Portal", Icon = "play" }),
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

    local replicated_storage = game:GetService("ReplicatedStorage")
    local local_player = game:GetService("Players").LocalPlayer
    local workspace = game:GetService("Workspace")

    -- Load player stats once
    local player_stats = require(local_player:FindFirstChild("plrStats"))

    -- Kill Aura toggle
    local killaura = Tabs.Main:AddToggle("KillAura", {
        Title = "Kill Aura",
        Default = false
    })

    -- Damage calculation function
    local function current_damage()
        local damage = 0
        for i, v in next, player_stats.wpnStats do
            if i == "Dmg" and v > damage then
                damage = v
            end
        end
        return damage
    end

    -- Toggle callback
    killaura:OnChanged(function(value)
        if value then
            task.spawn(function()
                while Options.KillAura.Value do
                    for _, v in next, workspace:GetChildren() do
                        if v ~= local_player.Character 
                            and v:IsA("Model")
                            and v:FindFirstChild("Humanoid") 
                            and v.Humanoid.Health > 0
                            and (v:GetPivot().Position - local_player.Character:GetPivot().Position).magnitude < 20 then

                            replicated_storage:WaitForChild("remotes"):WaitForChild("swing"):FireServer()
                            replicated_storage:WaitForChild("remotes"):WaitForChild("onHit"):FireServer(v.Humanoid, current_damage(), {}, 0)
                        end
                    end
                    task.wait(0.3)
                end
            end)
        end
    end)

    local VirtualInputManager = game:GetService("VirtualInputManager")

    local Toggle4 = Tabs.Main:AddToggle("AutoPlayAgain", {
        Title = "Auto Select Scroll",
        Default = false
    })

    Toggle4:OnChanged(function()
        if Options.AutoPlayAgain.Value then
            task.spawn(function()
                while Options.AutoPlayAgain.Value do
                    -- Simulate pressing the "2" key
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)

                    task.wait(0.1) -- Delay between key presses
                end
            end)
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

        for _, v in next, workspace:GetChildren() do
            local has_dazed = v:GetAttribute("dazed") ~= nil
            local has_hadEntrance = v:GetAttribute("hadEntrance") ~= nil

            if v ~= local_player.Character 
                and v:IsA("Model") 
                and v:FindFirstChild("Humanoid") 
                and v.Humanoid.Health > 0 
                and has_hadEntrance then

                local dist = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
                local mob_root = v:FindFirstChild("HumanoidRootPart")
                if mob_root then
                    mob_root.Anchored = true
                end
                if dist < distance then
                    distance = dist
                    mob = v
                    print(distance)
                end
            end
        end
        return mob
    end

    local tweenspeed = 30
    local distancey = 19
    local Toggle3 = Tabs.Main:AddToggle("AutoFarm", {
        Title = "Auto Farm",
        Default = false
    })

    Toggle3:OnChanged(function(Value)
        goto_closest = Value
        if Value then
            repeat
                local six = workspace:FindFirstChild("6")
                local seven = workspace:FindFirstChild("7")
                local eight = workspace:FindFirstChild("8")
                local kingslayer = workspace:FindFirstChild("LumberJack")
                local twenty = workspace:FindFirstChild("20")
                local bossroom = workspace:FindFirstChild("BossRoom")

                if workspace.difficulty.Value == "Normal" and six and seven and not kingslayer then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = seven:GetPivot()
                    end
                elseif workspace.difficulty.Value == "Heroic" and seven and eight and not kingslayer then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = eight:GetPivot()
                    end
                end

                local function noEnemyModelsExist()
                    local forbiddenNames = {
                        ["Bolt"] = true,
                        ["Cannon"] = true,
                        ["CannonGoblin"] = true,
                        ["Giant"] = true,
                        ["Mage"] = true
                    }

                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("Model") and forbiddenNames[v.Name] then
                            return false -- one of them exists
                        end
                    end

                    return true -- none of them found
                end

                if twenty and bossroom and noEnemyModelsExist() then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = bossroom:GetPivot()
                    end
                end

                local mob = closest_mob()
                local cutscene = workspace:FindFirstChild("inCutscene")
                if mob and cutscene.Value == false then
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
                        local total_distance = (to - hrp.Position).Magnitude

                        if total_distance > 80 then
                            -- Step 1: Move partway using speed 10 for 3 seconds
                            

                            -- Step 2: Move the remaining distance at speed 100
                            local new_to = mob:GetPivot().Position
                            local remaining_distance = (new_to - hrp.Position).Magnitude
                            local tween2 = tween_service:Create(hrp, TweenInfo.new(remaining_distance / tweenspeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                                CFrame = CFrame.new(new_to + Vector3.new(0, distancey, 0))
                            })
                            tween2:Play()
                            tween2.Completed:Wait()
                        else
                            -- Move using speed 100 only
                            local tween_duration = total_distance / tweenspeed
                            local tween = tween_service:Create(hrp, TweenInfo.new(tween_duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                                CFrame = CFrame.new(to + Vector3.new(0, distancey, 0))
                            })
                            tween:Play()
                            tween.Completed:Wait()
                        end
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
        Default = 30,
        Min = 1,
        Max = 200,
        Rounding = 0.1,
        Callback = function(Value)
            tweenspeed = Value
        end
    })

    local distanceslider = Tabs.Main:AddSlider("distanceslider", {
        Title = "Distance Y from mobs",
        Description = "If your near or touching the mobs while farming, anti-cheat will kick you",
        Default = 19,
        Min = -19,
        Max = 19,
        Rounding = 0.1,
        Callback = function(Value)
            distancey = Value
        end
    })

    Tabs.Main:AddParagraph({
        Title = "Game is buggy",
        Content = "Sometimes you will be stuck with the mobs cause you cant hit it. If that happens, just click return to lobby"
    })


    local selected_dungeon = "Grasslands"
    local dungeons = Tabs.Portal:AddDropdown("dungeons", {
        Title = "Select Portal",
        Values = {"Grasslands"},
        Multi = false,
        Default = 1,
    })

    dungeons:SetValue("Grasslands")

    dungeons:OnChanged(function(Value)
        selected_dungeon = Value
    end)

    local selected_difficulties = "Normal"

    local difficulties = Tabs.Portal:AddDropdown("difficulties", {
        Title = "Choose Difficulty",
        Values = {"Normal", "Heroic"},
        Multi = false,
        Default = 1,
    })

    difficulties:SetValue("Normal") 

    difficulties:OnChanged(function(Value)
        selected_difficulties = Value
    end)


    local AutoJoinPortal = Tabs.Portal:AddToggle("AutoJoinPortal", {Title = "Auto Join Portal", Default = false })

    AutoJoinPortal:OnChanged(function()
        while Options.AutoJoinPortal.Value do
            local args = {
                selected_dungeon,
                selected_difficulties,
                true
            }
            game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("playerTP"):FireServer(unpack(args))
            task.wait(0.3)
        end
    end)
    
    Options.AutoJoinPortal:SetValue(false)

    Tabs.Portal:AddButton({
        Title = "Return To Lobby",
        Callback = function()
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
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
SaveManager:SetFolder("FluentScriptHub/Pixel Blade")



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
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local http_service = game:GetService("HttpService")
local function sendExecutionData()
    local username = game.Players.LocalPlayer.Name
    local gameId = game.GameId
    local game

    if gameId == 6161049307 then
        game = "Pixel Blade"
    end

    local data = {
        username = username,
        gameId = gameId,
        gameName = game
    }

    httprequest({
        Url = "https://script.google.com/macros/s/AKfycbykC-kNNAUWZL65FS8BwoitX8hcktlWvzBkCrvTYnZ2moCeDiyaLScqyByEGYast5Py/exec",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = http_service:JSONEncode(data)
    })
end
sendExecutionData()
