local service = 4142;  -- your service id, this is used to identify your service.
local secret = "ead9af0c-59ce-44af-9623-681cf1eec6b3";  -- make sure to obfuscate this if you want to ensure security.
local useNonce = true;  -- use a nonce to prevent replay attacks and request tampering.


local onMessage = function(message) end;
repeat task.wait() until game:IsLoaded();


local requestSending = false;
local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor, fGetHwid = setclipboard or toclipboard, request or http_request or syn_request, string.char, tostring, string.sub, os.time, math.random, math.floor, gethwid or function() return game:GetService("Players").LocalPlayer.UserId end
local cachedLink, cachedTime = "", 0;
local HttpService = game:GetService("HttpService")

function lEncode(data)
	return HttpService:JSONEncode(data)
end

function lDecode(data)
    return HttpService:JSONDecode(data)  -- Changed from JSONEncode to JSONDecode
end

local function lDigest(input)
    local inputStr = tostring(input)
    local hash = {}
    for i = 1, #inputStr do
        table.insert(hash, string.byte(inputStr, i))
    end
    local hashHex = ""
    for _, byte in ipairs(hash) do
        hashHex = hashHex .. string.format("%02x", byte)
    end
    return hashHex
end

local function loadGame()
    repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mazino45/SaveManager/refs/heads/main/InterfaceManager"))()

    local Window = Fluent:CreateWindow({
        Title = "Dig to Earth's CORE!",
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
    icon.Size = UDim2.new(0, 65, 0, 60)
    icon.Position = UDim2.new(0, 200, 0, 150)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://121800415377798" 
    icon.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
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
        Main = Window:AddTab({ Title = "Main", Icon = "home" }),
        Hatch = Window:AddTab({ Title = "Auto Hatch", Icon = "home" }),
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
        local Toggle = Tabs.Main:AddToggle("AutoDigg", {Title = "Instant Dig", Description = "This will instant dig", Default = false })
        Toggle:OnChanged(function()
            task.spawn(function()
                if Options.AutoDigg.Value then
                    while Options.AutoDigg.Value do
                        local player = game.Players.LocalPlayer
                        if player:GetAttribute("InstantDig") == false then
                            player:SetAttribute("InstantDig", true)
                        end
                        if player:FindFirstChild("AutoDig") and player.AutoDig.Value == false then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AutoDigEvent"):FireServer()
                        end
                        wait(0.1)
                    end
                elseif Options.AutoDigg.Value == false then
                    game:GetService("Players").LocalPlayer.AutoDig.Value = false
                end
            end)
        end)
        Options.AutoDigg:SetValue(false)

    -- Auto Sell All
        local Toggle2 = Tabs.Main:AddToggle("InfCash", {Title = "Infinite Cash", Description = "This will give you money without digging", Default = false })
        Toggle2:OnChanged(function()
            task.spawn(function()
                while Options.InfCash.Value do
                    local args = {
                        "hello"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DigEvent"):FireServer(unpack(args))
                        
                    task.wait(0.1)
                end
            end)
        end)
        Options.InfCash:SetValue(false)
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
    SaveManager:SetFolder("FluentScriptHub/Dig to Earths CORE")



    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)


    Window:SelectTab(1)

    Fluent:Notify({
        Title = "Aeonic Hub",
        Content = "The script has been loaded.",
        Duration = 3
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
        if gameId == 7513130835 then
            game = "Untitled Drill Game"
        elseif gameId == 7468338447 then
            game = "Dig Earths Core"
        elseif gameId == 7519170515 then
            game = "Grow A Pond"
        elseif gameId == 7546582051 then
            game = "Dungeon Heroes"
        elseif gameId == 7436755782 then
            game = "Grow A Garden"
        elseif gameId == 6115988515 then
            game = "Anime Saga"
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
end
local host = "https://api.platoboost.com";
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
});
if hostResponse.StatusCode ~= 200 or hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net";
end

--!optimize 2
function cacheLink()
    if cachedTime + (10*60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({
                service = service,
                identifier = lDigest(fGetHwid())
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        });

        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body);

            if decoded.success == true then
                cachedLink = decoded.data.url;
                cachedTime = fOsTime();
                return true, cachedLink;
            else
                onMessage(decoded.message);
                return false, decoded.message;
            end
        elseif response.StatusCode == 429 then
            local msg = "you are being rate limited, please wait 20 seconds and try again.";
            onMessage(msg);
            return false, msg;
        end

        local msg = "Failed to cache link.";
        onMessage(msg);
        return false, msg;
    else
        return true, cachedLink;
    end
end

cacheLink();

--!optimize 2
local generateNonce = function()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
    end
    return str
end

--!optimize 1
for _ = 1, 5 do
    local oNonce = generateNonce();
    task.wait(0.2)
    if generateNonce() == oNonce then
        local msg = "platoboost nonce error.";
        onMessage(msg);
        error(msg);
    end
end

--!optimize 2
local copyLink = function()
    local success, link = cacheLink();
    
    if success then
		print("SetClipboard")
        fSetClipboard(link);
    end
end

--!optimize 2
local redeemKey = function(key)
    local nonce = generateNonce();
    local endpoint = host .. "/public/redeem/" .. fToString(service);

    local body = {
        identifier = lDigest(fGetHwid()),
        key = key
    }

    if useNonce then
        body.nonce = nonce;
    end

    local response = fRequest({
        Url = endpoint,
        Method = "POST",
        Body = lEncode(body),
        Headers = {
            ["Content-Type"] = "application/json"
        }
    });

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);

        if decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                        return true;
                    else
                        onMessage("failed to verify integrity.");
                        return false;
                    end    
                else
                    return true;
                end
            else
                onMessage("key is invalid.");
                return false;
            end
        else
            if fStringSub(decoded.message, 1, 27) == "unique constraint violation" then
                onMessage("you already have an active key, please wait for it to expire before redeeming it.");
                return false;
            else
                onMessage(decoded.message);
                return false;
            end
        end
    elseif response.StatusCode == 429 then
        onMessage("you are being rate limited, please wait 20 seconds and try again.");
        return false;
    else
        onMessage("server returned an invalid status code, please try again later.");
        return false; 
    end
end

--!optimize 2
local verifyKey = function(key)
    if requestSending == true then
        onMessage("a request is already being sent, please slow down.");
        return false;
    else
        requestSending = true;
    end

    local nonce = generateNonce();
    local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key;

    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce;
    end

    local response = fRequest({
        Url = endpoint,
        Method = "GET",
    });

    requestSending = false;

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);

        if decoded.success == true then
			print("true")
            if decoded.data.valid == true then
                if useNonce then
                    return true;
                else
                    return true;
                end
            else
                if fStringSub(key, 1, 4) == "KEY_" then
                    return redeemKey(key);
                else
                    onMessage("key is invalid.");
                    return false;
                end
            end
        else
            onMessage(decoded.message);
            return false;
        end
    elseif response.StatusCode == 429 then
        onMessage("you are being rate limited, please wait 20 seconds and try again.");
        return false;
    else
        onMessage("server returned an invalid status code, please try again later.");
        return false;
    end
end

--!optimize 2
local getFlag = function(name)
    local nonce = generateNonce();
    local endpoint = host .. "/public/flag/" .. fToString(service) .. "?name=" .. name;

    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce;
    end

    local response = fRequest({
        Url = endpoint,
        Method = "GET",
    });

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body);

        if decoded.success == true then
            if useNonce then
                if decoded.data.hash == lDigest(fToString(decoded.data.value) .. "-" .. nonce .. "-" .. secret) then
                    return decoded.data.value;
                else
                    onMessage("failed to verify integrity.");
                    return nil;
                end
            else
                return decoded.data.value;
            end
        else
            onMessage(decoded.message);
            return nil;
        end
    else
        return nil;
    end
end

-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local key = ""

local Window = Fluent:CreateWindow({
    Title = "Aeonic Hub",
    SubTitle = "by Adui",
    TabWidth = 130,
    Size = UDim2.fromOffset(500, 280),
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    KeySys = Window:AddTab({ Title = "Key System", Icon = "key" }),
}

local Entkey = Tabs.KeySys:AddInput("Input", {
    Title = "Enter Key",
    Default = "",
    Placeholder = "Enter key…",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        key = Value
    end
})

local Checkkey = Tabs.KeySys:AddButton({
    Title = "Check Key",
    Callback = function()
        local success = verifyKey(key)
        if success then
            Fluent:Notify({
                Title = "Aeonic Hub",
                Content = "Key Is Valid",
                Duration = 3 
            })
            Window:Destroy()
            loadGame()
        else
            Fluent:Notify({
                Title = "Aeonic Hub",
                Content = "Key Is Invalid",
                Duration = 3 
            })
        end
    end
})

local Getkey = Tabs.KeySys:AddButton({
    Title = "Get Key",
    Callback = function()
        copyLink()
        Fluent:Notify({
            Title = "Aeonic Hub",
            Content = "The link has been copied",
            Duration = 3
        })
    end
})

if key == "" and script_key then
	repeat wait() until game:IsLoaded()
	if game.Players.LocalPlayer then
	    key = script_key
        local success2 = verifyKey(key)
        if success2 then
			Fluent:Notify({
                Title = "Aeonic Hub",
                Content = "Key Is Valid",
                Duration = 3
            })
			Window:Destroy()
            loadGame()
        else
			Fluent:Notify({
                Title = "Aeonic Hub",
                Content = "Key Is Invalid",
                Duration = 3
            })
        end
	end
end
Window:SelectTab(1)