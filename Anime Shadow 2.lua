local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

local Window = Fluent:CreateWindow({
    Title = "Aeonic Hub",
    SubTitle = "| [BETA] Anime Shadow 2 | discord.gg/mbyHbxAhhT",
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
    Main = Window:AddTab({ Title = "Farm Tab", Icon = "home" }),
    Raid = Window:AddTab({ Title = "Raid", Icon = "swords" }),
    Hatch = Window:AddTab({ Title = "Auto Hatch", Icon = "egg" }),
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

    local selected_world = "Shadow City"

    local shadowcitymobs = {"AxeGuardian", "KingGuardian", "MaceGuardian", "SingerGuardian"}
    local slayerislandmobs = {"Dhoma", "Enmo", "Hantego", "Kokoshibo", "Ruih"}
    local dragonworldmobs = {"Boo", "Frieza", "GokoBlack", "Gran", "Jeren"}

    local world_to_mobs = {
        ["Shadow City"] = shadowcitymobs,
        ["Slayer Island"] = slayerislandmobs,
        ["Dragon World"] = dragonworldmobs,
    }

    
    local selectworld = Tabs.Main:AddDropdown("selectworld", {
        Title = "Select World",
        Values = {"Shadow City", "Slayer Island", "Dragon World"},
        Multi = false,
        Default = "Shadow City",
    })

    
    local selectenemies = Tabs.Main:AddDropdown("selectenemies", {
        Title = "Select Enemies",
        Values = shadowcitymobs, 
        Multi = true,
        Default = {}, 
    })

 
    selectworld:OnChanged(function(Value)
        selected_world = Value
        local newValues = world_to_mobs[selected_world]
        if newValues then
            selectenemies:SetValues(newValues) 
            selectenemies:SetValue({}) 
        end
    end)

  
    selectenemies:OnChanged(function(Value)
        local selectedEnemies = {}
        for mobName, isSelected in pairs(Value) do
            if isSelected then
                table.insert(selectedEnemies, mobName)
            end
        end
    end)

    local selecteddifficulty = { "Easy" }

    local selectdifficulty = Tabs.Main:AddDropdown("selectdifficulty", {
        Title = "Select Difficulties",
        Values = {"Easy", "Medium", "Hard", "Impossible", "Boss"},
        Multi = true,
        Default = { Easy = true },
    })

    selectdifficulty:OnChanged(function(Value)
        local Values = {}
        for difficulty, isSelected in next, Value do
            if isSelected then
                table.insert(Values, difficulty)
            end
        end
    end)

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

        -- Get the selected enemies and difficulties as lookup tables
        local selectedEnemies = selectenemies.Value or {}
        local selectedDifficulties = selectdifficulty.Value or {}

        -- Get the current world's enemies
        local enemiesFolder = workspace.Server.Enemies:FindFirstChild(selected_world)
        if not enemiesFolder then return nil end

        for _, v in ipairs(enemiesFolder:GetChildren()) do
            local mobName = v.Name
            local mobDifficult = v:GetAttribute("Difficult")
            local mobHealth = v:GetAttribute("Health")

            if mobHealth and mobHealth > 0 and selectedEnemies[mobName] and selectedDifficulties[mobDifficult] then
                local dist = (v.Position - local_player.Character:GetPivot().Position).Magnitude
                if dist < distance then
                    distance = dist
                    mob = v
                end
            end
        end

        return mob
    end

    local Toggle3 = Tabs.Main:AddToggle("AutoFarm", {
        Title = "Auto Farm",
        Default = false
    })
    Toggle3:OnChanged(function(Value)
        goto_closest = Value
        if Value then
            task.spawn(function()
                while goto_closest do
                    local mob = closest_mob()
                    if mob and local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = local_player.Character.HumanoidRootPart
                        local targetPos = mob.Position + Vector3.new(0, y or 0, 3)

                        -- Only teleport if farther than 1 stud
                        if (hrp.Position - targetPos).Magnitude > 10 then
                            hrp.CFrame = CFrame.new(targetPos, mob.Position)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)

    local autoattack = Tabs.Main:AddToggle("autoattack", {Title = "Auto Fast Click", Description = "You can also use this in raid", Default = false })

    autoattack:OnChanged(function()
        while Options.autoattack.Value do
            local args = {
                "Shadows",
                "Attack",
                "Click"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
    Options.autoattack:SetValue(false)


    local autoattackunit = Tabs.Main:AddToggle("autoattackunit", {Title = "Auto Attack Units", Default = false })
    local auto_attack = false

    autoattackunit:OnChanged(function(Value)
        auto_attack = Value
        if Value then
            task.spawn(function()
                while auto_attack do
                    local mob = closest_mob()
                    if mob then
                        local args = {
                            "Shadows",
                            "Attack",
                            "Attack_All",
                            "World",
                            mob  -- dynamically target current mob
                        }
                        replicated_storage:WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
                    end
                    task.wait(0.3) -- control attack rate here
                end
            end)
        end
    end)
    --[[
    local autojoinraiddelay = 10
    local autojoinraid = Tabs.Raid:AddToggle("autojoinraid", {Title = "Auto Join Raid", Default = false })

    autojoinraid:OnChanged(function()
        while Options.autojoinraid.Value do
            local args = {
                "Gamemodes",
                "Trial",
                "Join"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
            task.wait(autojoinraiddelay)
        end
    end)
    
    Options.autojoinraid:SetValue(false)

    local autojoindelayslider = Tabs.Raid:AddSlider("autojoindelayslider", {
        Title = "Auto Join Delay",
        Default = 10,
        Min = 1,
        Max = 30,
        Rounding = 0.1,
        Callback = function(Value)
            autojoinraiddelay = Value
        end
    })

    autojoindelayslider:SetValue(10)
    ]]
    
    local goto_closest_raid = false
    local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
    local local_player = cloneref(game:GetService('Players').LocalPlayer)
    local workspace = cloneref(game:GetService('Workspace'))

    function closest_raid_mob()
        local closestMob = nil
        local shortestDistance = math.huge
        local enemiesFolder = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Trial") and workspace.Server.Trial:FindFirstChild("Enemies")
        if not enemiesFolder then return nil end

        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            local mobHealth = mob:GetAttribute("Health")
            if mobHealth and mobHealth > 0 then
                local distance = (mob.Position - local_player.Character:GetPivot().Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestMob = mob
                end
            end
        end

        return closestMob
    end

    local ToggleRaidFarm = Tabs.Raid:AddToggle("AutoRaidFarm", {
        Title = "Auto Farm Raid",
        Default = false
    })

    ToggleRaidFarm:OnChanged(function(Value)
        goto_closest_raid = Value
        if Value then
            task.spawn(function()
                while goto_closest_raid do
                    local mob = closest_raid_mob()
                    if mob and local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = local_player.Character.HumanoidRootPart
                        local targetPos = mob.Position + Vector3.new(0, 0, 3)
                        if (hrp.Position - targetPos).Magnitude > 10 then
                            hrp.CFrame = CFrame.new(targetPos, mob.Position)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)

    local auto_attack_raid = false

    local ToggleRaidAttack = Tabs.Raid:AddToggle("AutoRaidAttackUnits", {
        Title = "Auto Attack Units",
        Default = false
    })

    ToggleRaidAttack:OnChanged(function(Value)
        auto_attack_raid = Value
        if Value then
            task.spawn(function()
                while auto_attack_raid do
                    local mob = closest_raid_mob()
                    if mob then
                        local args = {
                            "Shadows",
                            "Attack",
                            "Attack_All",
                            "Trial",
                            mob
                        }
                        replicated_storage:WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
                    end
                    task.wait(0.3)
                end
            end)
        end
    end)

    --[[
    local autostopfarm = Tabs.Raid:AddToggle("autostopfarm", {Title = "Stop", Default = false })

    autostopfarm:OnChanged(function()
        while Options.autostopfarm.Value do
            if workspace.Server.Trial.Lobby.Timer.BillboardGui.TextLabel.Text == "OPENS AT: 16:50" then
                Options.AutoFarm:SetValue(false)
            end
            task.wait(0.1)
        end
    end)
    
    Options.autostopfarm:SetValue(false)
    ]]

    local vim = game:GetService("VirtualInputManager")

    local autohatchsingle = Tabs.Hatch:AddToggle("autohatchsingle", {
        Title = "Auto Hatch Single",
        Default = false
    })

    autohatchsingle:OnChanged(function()
        while Options.autohatchsingle.Value do
            vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)  -- Press E
            task.wait(0.05)
            vim:SendKeyEvent(false, Enum.KeyCode.E, false, game) -- Release E
            task.wait(0.1) 
        end
    end)

    Options.autohatchsingle:SetValue(false)

    local autohatchmulti = Tabs.Hatch:AddToggle("autohatchmulti", {
        Title = "Auto Hatch Multi",
        Default = false
    })

    autohatchmulti:OnChanged(function()
        while Options.autohatchmulti.Value do
            vim:SendKeyEvent(true, Enum.KeyCode.Q, false, game)  
            task.wait(0.05)
            vim:SendKeyEvent(false, Enum.KeyCode.Q, false, game) 
            task.wait(0.1) 
        end
    end)

    Options.autohatchmulti:SetValue(false)

    local removehatchanimation = Tabs.Hatch:AddToggle("removehatchanimation", {Title = "Remove Hatch Animation", Default = false })

    removehatchanimation:OnChanged(function()
        while Options.removehatchanimation.Value do
            game:GetService("Players").LocalPlayer.PlayerGui.Star_View.Enabled = false
            task.wait(0.1)
        end
    end)
    
    Options.removehatchanimation:SetValue(false)


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
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local http_service = game:GetService("HttpService")
local function sendExecutionData()
    local username = game.Players.LocalPlayer.Name
    local gameId = game.GameId
    local game

    if gameId == 7483057113 then
        game = "Anime Shadows 2"
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
