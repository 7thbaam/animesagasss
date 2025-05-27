local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

local Window = Fluent:CreateWindow({
    Title = "Aeonic Hub",
    SubTitle = "| [RELEASE] Anime Saga | discord.gg/mbyHbxAhhT",
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
    Heal = Window:AddTab({ Title = "Auto Heal", Icon = "activity" }), 
    Skill = Window:AddTab({ Title = "Auto Skill", Icon = "skip-back" }),
    Change = Window:AddTab({ Title = "Change Character", Icon = "undo-2" }),
    Summon = Window:AddTab({ Title = "Summon", Icon = "gem" }),
    Dungeon = Window:AddTab({ Title = "Infinite Raid", Icon = "play" }),
    Webhook = Window:AddTab({ Title = "Webhook", Icon = "webcam" }),
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
    
    
    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")
    
    local function isMouseOverUI()
        return GuiService.MenuIsOpen or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
             or UserInputService:GetFocusedTextBox() ~= nil
    end
    
    local autoattack = Tabs.Main:AddToggle("autoattack", {Title = "Auto Attack", Default = false })
        
    autoattack:OnChanged(function()
        while Options.autoattack.Value do
            if not isMouseOverUI() then
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
            task.wait(0.1)
        end
    end)

    Options.autoattack:SetValue(false)

    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer

    local Toggle2 = Tabs.Main:AddToggle("AutoStart", {Title = "Auto Start", Default = false })

    Toggle2:OnChanged(function(value)
        if value then
            task.spawn(function()
                while Options.AutoStart.Value do
                    local remoteScript = localPlayer.PlayerGui:FindFirstChild("RoomUi")
                        and localPlayer.PlayerGui.RoomUi:FindFirstChild("Ready")
                        and localPlayer.PlayerGui.RoomUi.Ready:FindFirstChild("Frame")
                        and localPlayer.PlayerGui.RoomUi.Ready.Frame:FindFirstChild("StartButton")
                        and localPlayer.PlayerGui.RoomUi.Ready.Frame.StartButton:FindFirstChild("Butom")
                        and localPlayer.PlayerGui.RoomUi.Ready.Frame.StartButton.Butom:FindFirstChildWhichIsA("LocalScript")
                        
                    if remoteScript then
                        local foundRemote
                        for _, v in pairs(remoteScript:GetChildren()) do
                            if v:IsA("RemoteEvent") then
                                foundRemote = v
                                break
                            end
                        end
                        
                        if foundRemote then
                            foundRemote:FireServer()
                        end
                    end
                    
                    task.wait(0.5) -- Adjust delay if necessary
                end
            end)
        end
    end)

    Options.AutoStart:SetValue(false)

    local VirtualInputManager = game:GetService("VirtualInputManager")

    -- Function to get current character name
    local function getCurrentCharacter()
        local playerFolder = workspace:FindFirstChild("PlayerFodel")
        if not playerFolder then return nil end
        
        local playerInstance = playerFolder:FindFirstChild(localPlayer.Name)
        if not playerInstance then return nil end
        
        local skinFolder = playerInstance:FindFirstChild("Skin")
        if not skinFolder then return nil end
        
        -- Get the first child of Skin folder, which should be the character name
        for _, character in pairs(skinFolder:GetChildren()) do
            if character:IsA("Model") or character:IsA("Folder") then
                return character.Name
            end
        end
        
        return nil
    end

    -- Function to check if a skill is on cooldown
    local function isSkillOnCooldown(skillName)
        local playerFolder = workspace:FindFirstChild("PlayerFodel")
        if not playerFolder then return true end
        
        local playerInstance = playerFolder:FindFirstChild(localPlayer.Name)
        if not playerInstance then return true end
        
        local cooldownFolder = playerInstance:FindFirstChild("Cooldow")
        if not cooldownFolder then return true end
        
        local character = getCurrentCharacter()
        if not character then return true end
        
        -- Check if the specific skill is on cooldown
        return cooldownFolder:FindFirstChild(character .. "/" .. skillName) ~= nil
    end



    -- Skill hold times (how long each key is held)
    local zHoldTime, xHoldTime, cHoldTime, vHoldTime = 0.1, 0.1, 0.1, 0.1

    -- Sliders for key hold times
    Tabs.Skill:AddSlider("ZHoldTime", {
        Title = "Z Key Hold Time (seconds)",
        Default = 0.1,
        Min = 0.05,
        Max = 5.0,
        Rounding = 2,
        Callback = function(Value) zHoldTime = Value end
    }):SetValue(0.1)

    Tabs.Skill:AddSlider("XHoldTime", {
        Title = "X Key Hold Time (seconds)",
        Default = 0.1,
        Min = 0.05,
        Max = 5.0,
        Rounding = 2,
        Callback = function(Value) xHoldTime = Value end
    }):SetValue(0.1)

    Tabs.Skill:AddSlider("CHoldTime", {
        Title = "C Key Hold Time (seconds)",
        Default = 0.1,
        Min = 0.05,
        Max = 5.0,
        Rounding = 2,
        Callback = function(Value) cHoldTime = Value end
    }):SetValue(0.1)

    Tabs.Skill:AddSlider("VHoldTime", {
        Title = "V Key Hold Time (seconds)",
        Default = 0.1,
        Min = 0.05,
        Max = 5.0,
        Rounding = 2,
        Callback = function(Value) vHoldTime = Value end
    }):SetValue(0.1)

    -- Toggles
    local ToggleZ = Tabs.Skill:AddToggle("AutoZ", { Title = "Auto Press Z", Default = false })
    local ToggleX = Tabs.Skill:AddToggle("AutoX", { Title = "Auto Press X", Default = false })
    local ToggleC = Tabs.Skill:AddToggle("AutoC", { Title = "Auto Press C", Default = false })
    local ToggleV = Tabs.Skill:AddToggle("AutoV", { Title = "Auto Press V", Default = false })

    -- Independent skill casting functions
    local zConnection, xConnection, cConnection, vConnection

    -- Z skill function
    ToggleZ:OnChanged(function(value)
        if value then
            if zConnection then zConnection:Disconnect() end
            zConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not ToggleZ.Value then 
                    zConnection:Disconnect()
                    zConnection = nil
                    return
                end
                
                if not isSkillOnCooldown("Skill1") then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                    task.wait(zHoldTime)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
                end
                task.wait(0.05)
            end)
        elseif zConnection then
            zConnection:Disconnect()
            zConnection = nil
        end
    end)

    -- X skill function
    ToggleX:OnChanged(function(value)
        if value then
            if xConnection then xConnection:Disconnect() end
            xConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not ToggleX.Value then 
                    xConnection:Disconnect()
                    xConnection = nil
                    return
                end
                
                if not isSkillOnCooldown("Skill2") then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                    task.wait(xHoldTime)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
                end
                task.wait(0.05)
            end)
        elseif xConnection then
            xConnection:Disconnect()
            xConnection = nil
        end
    end)

    -- C skill function
    ToggleC:OnChanged(function(value)
        if value then
            if cConnection then cConnection:Disconnect() end
            cConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not ToggleC.Value then 
                    cConnection:Disconnect()
                    cConnection = nil
                    return
                end
                
                if not isSkillOnCooldown("Skill3") then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                    task.wait(cHoldTime)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
                end
                task.wait(0.05)
            end)
        elseif cConnection then
            cConnection:Disconnect()
            cConnection = nil
        end
    end)

    ToggleV:OnChanged(function(value)
        if value then
            if vConnection then vConnection:Disconnect() end
            vConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not ToggleV.Value then 
                    vConnection:Disconnect()
                    vConnection = nil
                    return
                end
                
                if not isSkillOnCooldown("Skill4") then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.V, false, game)
                    task.wait(vHoldTime)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.V, false, game)
                end
                task.wait(0.05)
            end)
        elseif vConnection then
            vConnection:Disconnect()
            vConnection = nil
        end
    end)

    -- Clean up connections when script ends
    game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
        if zConnection then zConnection:Disconnect(); zConnection = nil end
        if xConnection then xConnection:Disconnect(); xConnection = nil end
        if cConnection then cConnection:Disconnect(); cConnection = nil end
        if vConnection then vConnection:Disconnect(); vConnection = nil end
    end)

    
    local Toggle4 = Tabs.Main:AddToggle("AutoPlayAgain", {Title = "Auto Replay", Default = false })
    
    Toggle4:OnChanged(function()
        while Options.AutoPlayAgain.Value do
            local win = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Win")
            
            if win and win.Enabled then
                game:GetService("ReplicatedStorage").Events.WinEvent.Buttom:FireServer("RPlay")
            end
            wait(0.1)
        end
    end)
    
    Options.AutoPlayAgain:SetValue(false)
    
    local autonext = Tabs.Main:AddToggle("autonext", {Title = "Auto Next", Default = false })
    
    autonext:OnChanged(function()
        while Options.autonext.Value do
            local win = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Win")
            
            if win and win.Enabled then
                game:GetService("ReplicatedStorage").Events.WinEvent.Buttom:FireServer("NextLv")
            end
            wait(0.1)
        end
    end)
    
    Options.autonext:SetValue(false)
    
    
    local goto_closest = false
    
    local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
    local user_input_service = cloneref(game:GetService('UserInputService'))
    local local_player = cloneref(game:GetService('Players').LocalPlayer)
    local tween_service = cloneref(game:GetService('TweenService'))
    local run_service = cloneref(game:GetService('RunService'))
    local workspace = cloneref(game:GetService('Workspace'))
    
    local enemies = workspace:FindFirstChild("Enemy")
    function closest_mob()
        local mob = nil
        local distance = math.huge
        
        for _, v in next, enemies.Mob:GetChildren() do
            local humanoid = v:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local dist = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
                if dist < distance then
                    distance = dist
                    mob = v
                end
            end
        end
        return mob
    end
    
    local y = 8
    local y_vertical = 0
    local tween_speed = 200
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
                        local mobCFrame = mob:GetPivot()
                        local backwardVector = -mobCFrame.LookVector
                        local targetPosXZ = mobCFrame.Position + backwardVector * y
                        local rayOrigin = targetPosXZ + Vector3.new(0, 10, 0) -- start ray above expected ground
                        local rayDir = Vector3.new(0, -100, 0) -- ray downwards

                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {mob, local_player.Character}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude

                        local rayResult = workspace:Raycast(rayOrigin, rayDir, rayParams)

                        local groundY = rayResult and rayResult.Position.Y or targetPosXZ.Y -- fallback in case ray misses
                        local targetPosition = Vector3.new(targetPosXZ.X, groundY, targetPosXZ.Z)

                        
                        local distance = (targetPosition - hrp.Position).Magnitude
                        local tween = tween_service:Create(hrp, TweenInfo.new(distance / tween_speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                            CFrame = CFrame.new(targetPosition, mobCFrame.Position) -- face the mob
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
    Options.AutoFarm:SetValue(false)

    local tweenspeed = Tabs.Main:AddSlider("tweenspeed", {
        Title = "Tween Speed",
        Default = 200,
        Min = 20,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            tween_speed = Value
        end
    })
    tweenspeed:SetValue(200)
    local Distance = Tabs.Main:AddSlider("Distance", {
        Title = "Distance Behind Mob",
        Default = 8,
        Min = 0,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            y = Value
        end
    })
    
    Distance:SetValue(8)
    
    --[[
    local autododge = Tabs.Main:AddToggle("autododge", {Title = "Auto Dodge", Default = false })
    local isDodging = false
    local lastDodgeTime = 0
    local dodgeCooldown = 0.1
    local activeHitboxes = {}
    local dangerousDirections = {} 

    -- Enhanced hitbox detection with threat assessment
    local function checkHitboxes()
        local now = tick()
        local threats = {}
        local mostDangerous = nil
        local highestThreatScore = 0
        
        -- Clear expired hitboxes
        for hitbox, spawnTime in pairs(activeHitboxes) do
            if not hitbox:IsDescendantOf(workspace) or (now - spawnTime) > 2 then
                activeHitboxes[hitbox] = nil
                dangerousDirections[hitbox] = nil
            end
        end
        
        -- Analyze all active hitboxes
        for _, mob in ipairs(workspace.Enemy.Mob:GetChildren()) do
            local hitbox = mob:FindFirstChild("Hitbox1")
            if hitbox and hitbox:IsA("BasePart") then
                -- Track new hitboxes
                if not activeHitboxes[hitbox] then
                    activeHitboxes[hitbox] = now
                end
                
                -- Calculate threat metrics
                local dist = (hitbox.Position - local_player.Character.HumanoidRootPart.Position).Magnitude
                local age = now - activeHitboxes[hitbox]
                local threatScore = (1/dist) * (1/age) -- Higher for closer/newer threats
                
                -- Store threat data
                threats[hitbox] = {
                    distance = dist,
                    age = age,
                    score = threatScore,
                    position = hitbox.Position
                }
                
                -- Track most dangerous threat
                if threatScore > highestThreatScore then
                    highestThreatScore = threatScore
                    mostDangerous = hitbox
                end
            end
        end
        
        return threats, mostDangerous
    end

    -- Calculate optimal dodge direction considering multiple threats
    local function calculateDodgeDirection(hrp, threats)
        local combinedDirection = Vector3.new(0,0,0)
        local threatCount = 0
        
        -- Sum directions away from all active threats
        for hitbox, data in pairs(threats) do
            if data.distance < 20 then -- Only consider nearby threats
                local awayVector = (hrp.Position - data.position).Unit
                combinedDirection = combinedDirection + awayVector
                threatCount = threatCount + 1
            end
        end
        
        -- Default to random direction if no immediate threats
        if threatCount == 0 then
            return Vector3.new(math.random(-1,1), 0, math.random(-1,1)).Unit
        end
        
        -- Normalize and add upward component
        return (combinedDirection/threatCount + Vector3.new(0,0.3,0)).Unit
    end

    autododge:OnChanged(function()
        task.spawn(function()
            while Options.autododge.Value do
                if not isDodging and (tick() - lastDodgeTime) > dodgeCooldown then
                    local threats, mostDangerous = checkHitboxes()
                    
                    -- Dodge if any threat is close and recent
                    if mostDangerous and threats[mostDangerous].distance < 20 
                    and threats[mostDangerous].age < 1.5 then
                        isDodging = true
                        local originalFarmState = goto_closest
                        
                        if originalFarmState then
                            Options.AutoFarm:SetValue(false)
                            task.wait(0.1)
                        end
                        
                        local character = local_player.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local hrp = character.HumanoidRootPart
                            
                            -- Calculate optimal dodge direction considering all threats
                            local dodgeDirection = calculateDodgeDirection(hrp, threats)
                            
                            -- Dynamic dodge distance based on threat density
                            local threatDensity = 0
                            for _, data in pairs(threats) do
                                if data.distance < 15 then
                                    threatDensity = threatDensity + 1
                                end
                            end
                            
                            local dodgeDistance = math.clamp(50 + (threatDensity * 5), 20, 50)
                            local dodgePosition = hrp.Position + (dodgeDirection * dodgeDistance)
                            
                            -- Boundary check
                            if dodgePosition.Y < 0 then
                                dodgePosition = Vector3.new(dodgePosition.X, 5, dodgePosition.Z)
                            end
                            
                            -- Adjust duration based on distance and threat count
                            local dodgeDuration = math.clamp(dodgeDistance/40 + (threatDensity * 0.05), 0.2, 0.6)
                            
                            -- Execute dodge
                            local tween = tween_service:Create(
                                hrp,
                                TweenInfo.new(dodgeDuration, Enum.EasingStyle.Linear),
                                {CFrame = CFrame.new(dodgePosition)}
                            )
                            tween:Play()
                            tween.Completed:Wait()
                            
                            -- Smarter recovery time based on threat analysis
                            local recoveryTime = math.clamp(1.8 - threats[mostDangerous].age, 0.6, 1.8)
                            task.wait(recoveryTime)
                        end
                        
                        if originalFarmState then
                            Options.AutoFarm:SetValue(true)
                        end
                        
                        lastDodgeTime = tick()
                        isDodging = false
                    end
                end
                task.wait(0.1)
            end
        end)
    end)
    ]]

    Tabs.Heal:AddParagraph({
        Title = "Read This, Very Important!",
        Content = "If you want auto heal while auto farming, this is the steps so read carefully. Before that you need to make sure first that auto farm dungeon is off or else it will break. STEP1: You need to on important toggle STEP2: Toggle On Auto Consume Potion STEP3: Input the health where you will start auto healing STEP4: Toggle On Auto Crate and all your settings that you want to be on. You don't need to turn on auto farm dungeon. Only use this steps if you want to auto heal while farming. Thats it Enjoy!. NOTE: THIS IS ONLY FOR SLOT 1 CHARACTERS"
    })
    local goto_closest_crate = false
    local selected_health = 50
    -- Function to find closest crate
    function closest_crate()
        local crate = nil
        local distance = math.huge
        for _, v in next, enemies.Crate:GetChildren() do
            local humanoid = v:FindFirstChild("HumanoidRootPart")
            if humanoid then
                local dist = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
                if dist < distance then
                    distance = dist
                    crate = v
                end
            end
        end
        return crate
    end
    
    local autocrate = Tabs.Heal:AddToggle("autocrate", { Title = "Auto Crate", Default = false })
    local wasFarmEnabled = false  -- Track previous AutoFarm state

    autocrate:OnChanged(function(Value)
        if Value then
            wasFarmEnabled = Options.AutoFarm.Value  -- Store current AutoFarm state
            task.spawn(function()
                while Options.autocrate.Value do
                    local currenthealth = game:GetService("Players").LocalPlayer.CharValue.Slot1.Health.Value
                    local maxhealth = game:GetService("Players").LocalPlayer.CharValue.Slot1.MaxHealth.Value
                    
                    if currenthealth <= tonumber(selected_health) or 
                    (currenthealth > tonumber(selected_health) and currenthealth < maxhealth) then
                        -- Only disable AutoFarm if it's not already disabled
                        if Options.AutoFarm.Value then
                            Options.AutoFarm:SetValue(false)
                        end
                        
                        -- Your crate movement code here
                        local crate = closest_crate()
                        if crate then
                            task.wait(.1)
                            local velocity_connection = run_service.Heartbeat:Connect(function()
                                if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                                    local_player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                    local_player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                                end
                            end)
                            local character = local_player.Character
                            local hrp = character and character:FindFirstChild("HumanoidRootPart")
                            if hrp and crate then
                                local to = crate:GetPivot().Position
                                local crateCFrame = crate:GetPivot()
                                local backwardVector = -crateCFrame.LookVector
                                local targetPosition = crateCFrame.Position + backwardVector * 8 + Vector3.new(0, 0, 0)
                                    
                                local distance = (targetPosition - hrp.Position).Magnitude
                                local tween = tween_service:Create(hrp, TweenInfo.new(distance / tween_speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                                    CFrame = CFrame.new(targetPosition, crateCFrame.Position) -- face the mob
                                })
                                tween:Play()
                                tween.Completed:Wait()
                                
                            end
                            if velocity_connection then
                                velocity_connection:Disconnect()
                            end
                        end
                        task.wait()
                    elseif currenthealth == maxhealth then
                        Options.AutoFarm:SetValue(true)
                        -- Just stop moving to crates
                    end
                    task.wait(0.1)
                end
                
                -- When autocrate is turned off, restore AutoFarm to its original state
                if not Options.autocrate.Value and wasFarmEnabled then
                    Options.AutoFarm:SetValue(wasFarmEnabled)
                end
            end)
        else
            -- When autocrate is turned off, restore AutoFarm to its original state
            if wasFarmEnabled then
                Options.AutoFarm:SetValue(wasFarmEnabled)
            end
        end
    end)
    Options.autocrate:SetValue(false)

    local health = Tabs.Heal:AddInput("health", {
        Title = "Health",
        Default = "50",
        Placeholder = "Placeholder",
        Numeric = true, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            selected_health = Value
        end
    })

    -- Auto Heal Code
    local autoheal = Tabs.Heal:AddToggle("autoheal", { Title = "Auto Consume Potion", Default = false })
    autoheal:OnChanged(function()
        task.spawn(function()
            while Options.autoheal.Value do
                local potion = game.Workspace:FindFirstChild("Potion")
                if potion then
                    for _, healing in pairs(potion:GetChildren()) do
                        local part = healing:FindFirstChild("Part")
                        if part then
                            for _, chatui in pairs(part:GetChildren()) do
                                if chatui.Name == "ChatUI" then
                                    fireproximityprompt(chatui)
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end)

    Options.autoheal:SetValue(false)

    local important = Tabs.Heal:AddToggle("important", {Title = "important", Default = false })

    important:OnChanged(function()
        while Options.important.Value do
            local currenthealth = game:GetService("Players").LocalPlayer.CharValue.Slot1.Health.Value
            local maxhealth = game:GetService("Players").LocalPlayer.CharValue.Slot1.MaxHealth.Value
            if currenthealth <= tonumber(selected_health) then
                print(selected_health)
                Options.AutoFarm:SetValue(false)
            end
            task.wait(0.1)
        end
    end)
    
    Options.important:SetValue(false)

    local autosummon = Tabs.Summon:AddToggle("autosummon", {Title = "Auto Summon", Default = false })

    autosummon:OnChanged(function()
        while Options.autosummon.Value do
            local args = {
                1
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("Summon"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
    
    Options.autosummon:SetValue(false)

    local autoclick = Tabs.Summon:AddToggle("autoclick", {Title = "Auto Click", Default = false })

    autoclick:OnChanged(function()
        while Options.autoclick.Value do
            if not isMouseOverUI() then
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
            task.wait(0.1)
        end
    end)
    
    Options.autoclick:SetValue(false)
    

    
    
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

    local infiniteraid = Tabs.Dungeon:AddToggle("infiniteraid", {Title = "Auto Infinite Raid", Description = "On this if your in lobby", Default = false })
    infiniteraid:OnChanged(function()
        if Options.infiniteraid.Value then
            task.wait(3)
            local plr = game:GetService("Players").LocalPlayer
            local raid = plr.PlayerGui.Window.Raid
            game:GetService("ReplicatedStorage").PlayerData[plr.Name].Stast.Level.Value = 100
            raid.Enabled = true
            raid.Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
            task.wait(0.1)
            local args = {
                "Create",
                "Raid",
                1,
                1,
                1,
                false
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("JoinRoom"):FireServer(unpack(args))
            task.wait(0.1)
            local arg2 = {
                "TeleGameplay",
                "Raid",
                1,
                1,
                1,
                false
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("JoinRoom"):FireServer(unpack(arg2))
        end
    end)
    
    Options.infiniteraid:SetValue(false)
    returntolobbydelay = 6
    local returntolobby = Tabs.Dungeon:AddToggle("returntolobby", {Title = "Return To Lobby", Default = false })
    returntolobby:OnChanged(function()
        while Options.returntolobby.Value do
            local win = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Win")
            
            if win then
                task.wait(returntolobbydelay)
                local player = game.Players.LocalPlayer
                local remote = player.PlayerGui
                    .Window.Settings.Frame.ScrollingFrame.ReturnLobby
                    .Background.Main.Button.Button.LocalScript.RemoteEvent

                remote:FireServer(player)
            end
            task.wait(0.1)
        end
    end)
    
    Options.returntolobby:SetValue(false)

    
    local returndelay = Tabs.Main:AddSlider("returndelay", {
        Title = "Return to lobby delay",
        Default = 6,
        Min = 1,
        Max = 20,
        Rounding = 0.1,
        Callback = function(Value)
            returntolobbydelay = Value
        end
    })

    returndelay:SetValue(6)

    local changedelay = 2
    local change = Tabs.Change:AddToggle("change", {Title = "Auto Change Character", Default = false })

    change:OnChanged(function()
        while Options.change.Value do
            task.wait(changedelay)
            local args = {
                game:GetService("Players").LocalPlayer
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ChangeChar"):FireServer(unpack(args))
        end
    end)
    
    Options.change:SetValue(false)

    local characterdelay = Tabs.Change:AddSlider("characterdelay", {
        Title = "Delay",
        Default = 2,
        Min = 0.1,
        Max = 20,
        Rounding = 1,
        Callback = function(Value)
            changedelay = Value
        end
    })

    characterdelay:SetValue(2)

    local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    local http_service = game:GetService("HttpService")
    local players = game:GetService("Players")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local localPlayer = players.LocalPlayer
    local autowebhook = Tabs.Webhook:AddToggle("autowebhook", {Title = "Webhook", Description = "For raid. Have a 5 sec delay before sending webhook", Default = false })
    local webhookurl = ""

    autowebhook:OnChanged(function()
        while Options.autowebhook.Value do
            local win = localPlayer.PlayerGui:FindFirstChild("Win")
            if win and win.Enabled then
                task.wait(5)
                local rewards = {}
                local scrollingFrame = win.Frame.progmain.reward:FindFirstChild("ScrollingFrame")

                if scrollingFrame then
                    for _, reward in pairs(scrollingFrame:GetChildren()) do
                        if reward.Name == "ItemReawrd" then
                            local blockImage = reward:FindFirstChild("BlockImage")
                            local textLabel = reward:FindFirstChild("TextLabel")
                            local worldModel = blockImage and blockImage:FindFirstChild("WorldModel")

                            if worldModel and textLabel then
                                local quantity = textLabel.Text
                                local children = worldModel:GetChildren()

                                if #children == 0 then
                                    table.insert(rewards, {
                                        type = "Gems",
                                        quantity = quantity
                                    })
                                else
                                    local firstChild = children[1]
                                    if firstChild then
                                        table.insert(rewards, {
                                            type = "Item",
                                            name = firstChild.Name,
                                            quantity = quantity
                                        })
                                    end
                                end
                            end
                        end
                    end

                    local progMain = win.Frame.progmain
                    local playtime = progMain.time.playtime.Text
                    local totalDamage = progMain.damage.Damage.Text
                    local level = progMain.lvl.Level.OnLevel.Text
                    local expStatus = progMain.lvl.Level.ExpLoad.Text
                    local expGain = progMain.lvl.Level.Exp.Text
                    local playerName = localPlayer.Name

                    -- Get Gold and Gems from ReplicatedStorage
                    local playerData = replicatedStorage:FindFirstChild("PlayerData"):FindFirstChild(playerName)
                    local stats = playerData and playerData:FindFirstChild("Stast")
                    local gold = stats and stats:FindFirstChild("Gold") and stats.Gold.Value or "N/A"
                    local gems = stats and stats:FindFirstChild("Gems") and stats.Gems.Value or "N/A"

                    local rewardText = ""
                    for _, r in ipairs(rewards) do
                        if r.type == "Gems" then
                            rewardText = rewardText .. "💎 Gems " .. r.quantity .. "\n"
                        else
                            rewardText = rewardText .. "🎁 " .. r.name .. " ".. r.quantity .. "\n"
                        end
                    end
                    if rewardText == "" then rewardText = "None" end

                    local embedPayload = {
                        embeds = {{
                            title = "🎉 Anime Saga Reward Tracker",
                            color = 5814783,
                            fields = {
                                {
                                    name = "👤 Player Info",
                                    value = "**Name:** " .. playerName ..
                                            "\n**Level:** " .. level ..
                                            "\n**EXP:** " .. expStatus ..
                                            "\n**EXP Gained:** " .. expGain ..
                                            "\n**Gold:** " .. tostring(gold) ..
                                            "\n**Gems:** " .. tostring(gems),
                                    inline = false
                                },
                                {
                                    name = "📦 Rewards",
                                    value = rewardText,
                                    inline = false
                                },
                                {
                                    name = "📊 Match Result",
                                    value = "**Playtime:** " .. playtime ..
                                            "\n**Total Damage:** " .. totalDamage,
                                    inline = false
                                }
                            },
                            footer = {
                                text = "Aeonic Hub • discord.gg/mbyHbxAhhT"
                            },
                            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                        }}
                    }

                    httprequest({
                        Url = webhookurl,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json"
                        },
                        Body = http_service:JSONEncode(embedPayload)
                    })
                    break
                end
            end
            task.wait(0.1)
        end
    end)

    Options.autowebhook:SetValue(false)

    local WebhookUrl = Tabs.Webhook:AddInput("WebhookUrl", {
        Title = "Webhook Url",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            webhookurl = Value
        end
    })



    -- Add this to your Settings tab section
    local hideUIToggle = Tabs.Settings:AddToggle("HideUI", {
        Title = "Hide UI",
        Default = false,
        Callback = function(Value)
            if Value then
                Window:Minimize(Value)
                Fluent:Notify({
                    Title = "UI Hidden",
                    Content = "Press LeftCtrl or click the cat to show UI again",
                    Duration = 3
                })
            end
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
SaveManager:SetFolder("FluentScriptHub/Anime Saga")



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