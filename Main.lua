-- ==============================================================================
-- WANGCAOS PREMIUM CLIENT V6.9.4 - COMPACT UI & DISCORD INTRO
-- ALL RIGHTS RESERVED BY DAI CA WANG (2026)
-- UI Design inspired by provided image (Minimalism/Dark/Blur/Boxes/Pill Toggles)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local MasterLoop

-- Modern Theme Colors (Dark/Minimalism)
local Style_Bg = Color3.fromRGB(15, 16, 17)
local Style_SubBg = Color3.fromRGB(22, 24, 27)
local Style_Accent = Color3.fromRGB(210, 80, 50) -- Warm reddish-orange for active elements
local Style_Inactive = Color3.fromRGB(40, 42, 45)
local Style_Text_Primary = Color3.fromRGB(255, 255, 255)
local Style_Text_Secondary = Color3.fromRGB(150, 150, 150)
local Style_CornerRadius = UDim.new(0, 5) -- Modern subtle corners
local Style_Font = Enum.Font.Gotham -- Clean sans-serif
local Style_Padding = UDim.new(0, 10)
local Style_ElementHeight = 32

local Config = {
    MenuVisible = true, MenuKeybind = Enum.KeyCode.RightShift,
    Aimbot = false, AimbotKeybind = Enum.KeyCode.E, TeamCheck = true, WallCheck = true, Smoothness = 5, TargetPart = "Head",
    Aura = false, AuraKeybind = Enum.KeyCode.H, TeamCheckAura = true, AuraWallCheck = true, AuraSmoothness = 5, AuraRadius = 30, AuraColor = Color3.fromRGB(0, 170, 255), AuraTransparency = 50, PriorityLowestHealth = false,
    Triggerbot = false, TriggerbotKeybind = Enum.KeyCode.T, TriggerWallCheck = true,
    Spinbot = false, SpinbotKeybind = Enum.KeyCode.K, SpinSpeed = 25,
    AutoFarmPlayer = false, AutoFarmDelay = 0.05,
    BowDown = false, BowAngle = 45, ThirdPerson = false, ThirdPersonDist = 15, AntiAFK = false,
    EspMaster = false, EspMasterKeybind = Enum.KeyCode.O, EspTeamCheck = false, FovCircle = false, FovRadius = 120, FovThickness = 1.5, FovSides = 64, FovColor = Color3.fromRGB(255, 255, 255), FovTransparency = 0.8, FovFilled = false,
    CrosshairDot = false, EspBox = false, EspTracer = false, TracerMode = "Bottom", EspColor = Color3.fromRGB(255, 50, 50), EspName = false, EspHealth = false, EspTransparency = 80, MaxDistance = 5000,
    SpeedToggle = false, SpeedKeybind = Enum.KeyCode.Q, WalkSpeed = 16, JumpToggle = false, JumpKeybind = Enum.KeyCode.G, JumpPower = 50,
    Fly = false, FlyKeybind = Enum.KeyCode.F, FlySpeed = 50, FullBright = false,
    ShowMobileAim = false, ShowMobileTrig = false, ShowMobileSpeed = false, ShowMobileFarm = false, ShowMobileAura = false, ShowMobileTP = false, ShowMobileFly = false, LockMobileButtons = false, 
    CustomBackground = true, BackgroundAssetId = "rbxassetid://118670919014080", StoredAmbient = Lighting.Ambient, StoredOutdoorAmbient = Lighting.OutdoorAmbient
}

local CurrentSpinAngle = 0
local IsMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
local LastFarmTime = 0
local CurrentFarmIndex = 1

local UI_Refresh_Functions = {}
local GlobalMobileButtons = {} 
local GlobalSyncToggles = {}

local flyBodyGyro
local flyBodyVelocity

local function GetSafeGui()
    local success, hui = pcall(function() return gethui() end)
    if success and hui then return hui end
    local success2, core = pcall(function() return CoreGui end)
    if success2 and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui", 10)
end

local SafeParent = GetSafeGui()
if not SafeParent then return end

for _, old in pairs(SafeParent:GetChildren()) do
    if old.Name == "Wangcaos_Premium_Figma_UI" or old.Name == "WangcaosIntro" then old:Destroy() end
end

-- Animated Intro Loading Screen
local IntroScreen = Instance.new("ScreenGui")
IntroScreen.Name = "WangcaosIntro"
IntroScreen.Parent = SafeParent
IntroScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local IntroFrame = Instance.new("Frame", IntroScreen)
IntroFrame.BackgroundColor3 = Style_Bg
IntroFrame.BackgroundTransparency = 0.05
IntroFrame.BorderSizePixel = 0
IntroFrame.Position = UDim2.new(0.5, -175, 0.5, -75)
IntroFrame.Size = UDim2.new(0, 350, 0, 150)
Instance.new("UICorner", IntroFrame).CornerRadius = Style_CornerRadius
local IntroStroke = Instance.new("UIStroke", IntroFrame)
IntroStroke.Color = Style_Accent 
IntroStroke.Thickness = 1.5

local IntroTitle = Instance.new("TextLabel", IntroFrame)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Size = UDim2.new(1, 0, 0, 40)
IntroTitle.Position = UDim2.new(0, 0, 0, 15)
IntroTitle.Font = Enum.Font.GothamBold
IntroTitle.Text = "WANGCAOS PREMIUM V6.9.4"
IntroTitle.TextColor3 = Style_Text_Primary
IntroTitle.TextSize = 18

local IntroDisc = Instance.new("TextLabel", IntroFrame)
IntroDisc.BackgroundTransparency = 1
IntroDisc.Size = UDim2.new(1, 0, 0, 20)
IntroDisc.Position = UDim2.new(0, 0, 0, 50)
IntroDisc.Font = Enum.Font.GothamBold
IntroDisc.Text = "Discord: Https://discord.gg/GkAKn4zzH"
IntroDisc.TextColor3 = Style_Accent
IntroDisc.TextSize = 12

local IntroSub = Instance.new("TextLabel", IntroFrame)
IntroSub.BackgroundTransparency = 1
IntroSub.Size = UDim2.new(1, 0, 0, 20)
IntroSub.Position = UDim2.new(0, 0, 0, 85)
IntroSub.Font = Style_Font
IntroSub.Text = "Initializing..."
IntroSub.TextColor3 = Style_Text_Secondary
IntroSub.TextSize = 12

-- Dynamic Loading Bar
local LoadingBg = Instance.new("Frame", IntroFrame)
LoadingBg.Position = UDim2.new(0, 25, 1, -25)
LoadingBg.Size = UDim2.new(1, -50, 0, 4)
LoadingBg.BackgroundColor3 = Style_Inactive
Instance.new("UICorner", LoadingBg).CornerRadius = UDim.new(1, 0)

local LoadingFill = Instance.new("Frame", LoadingBg)
LoadingFill.Size = UDim2.new(0, 0, 1, 0)
LoadingFill.BackgroundColor3 = Style_Accent
Instance.new("UICorner", LoadingFill).CornerRadius = UDim.new(1, 0)

pcall(function()
    if setclipboard then setclipboard("Https://discord.gg/GkAKn4zzH")
    elseif toclipboard then toclipboard("Https://discord.gg/GkAKn4zzH") end
end)

task.spawn(function()
    IntroSub.Text = "Loading Core Modules..."
    TweenService:Create(LoadingFill, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {Size = UDim2.new(0.35, 0, 1, 0)}):Play()
    task.wait(0.6)
    
    IntroSub.Text = "Bypassing Security Protocols..."
    TweenService:Create(LoadingFill, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {Size = UDim2.new(0.75, 0, 1, 0)}):Play()
    task.wait(0.8)
    
    IntroSub.Text = "Injecting Interface..."
    TweenService:Create(LoadingFill, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.4)
    
    IntroSub.Text = "Framework successfully loaded!"
    task.wait(1)
    
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(IntroFrame, tweenInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(IntroTitle, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(IntroDisc, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(IntroSub, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(IntroStroke, tweenInfo, {Transparency = 1}):Play()
    TweenService:Create(LoadingBg, tweenInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadingFill, tweenInfo, {BackgroundTransparency = 1}):Play()
    task.wait(0.8)
    if IntroScreen then IntroScreen:Destroy() end
end)
local function ExportSettings()
    local exportTable = {}
    for k, v in pairs(Config) do
        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then exportTable[k] = v
        elseif typeof(v) == "EnumItem" then exportTable[k] = {__type = "EnumItem", EnumType = tostring(v.EnumType), Name = v.Name}
        elseif typeof(v) == "Color3" then exportTable[k] = {__type = "Color3", R = v.R, G = v.G, B = v.B} end
    end
    local success, json = pcall(function() return HttpService:JSONEncode(exportTable) end)
    if not success then return "" end
    local hex = ""
    for i = 1, #json do hex = hex .. string.format("%02X", string.byte(json, i)) end
    return hex
end

local function ImportSettings(hexStr)
    local success, err = pcall(function()
        local json = ""
        for i = 1, #hexStr, 2 do
            local hexByte = string.sub(hexStr, i, i+1)
            if not hexByte or #hexByte < 2 then break end
            json = json .. string.char(tonumber(hexByte, 16))
        end
        local importTable = HttpService:JSONDecode(json)
        for k, v in pairs(importTable) do
            if type(v) == "table" and v.__type then
                if v.__type == "EnumItem" then
                    local enumType = string.split(v.EnumType, ".")[3] or v.EnumType
                    pcall(function() Config[k] = Enum[enumType][v.Name] end)
                elseif v.__type == "Color3" then Config[k] = Color3.new(v.R, v.G, v.B) end
            else Config[k] = v end
        end
        for _, refresh in pairs(UI_Refresh_Functions) do pcall(refresh) end
        for key, mData in pairs(GlobalMobileButtons) do
            local xs, xo, ys, yo = Config["MobilePos_"..key.."_XS"], Config["MobilePos_"..key.."_XO"], Config["MobilePos_"..key.."_YS"], Config["MobilePos_"..key.."_YO"]
            if xs and xo and ys and yo and mData.Btn then pcall(function() mData.Btn.Position = UDim2.new(xs, xo, ys, yo) end) end
        end
    end)
    return success
end

local FOV_Drawing = Drawing.new("Circle")
FOV_Drawing.Color = Config.FovColor; FOV_Drawing.Thickness = Config.FovThickness; FOV_Drawing.NumSides = Config.FovSides
FOV_Drawing.Filled = Config.FovFilled; FOV_Drawing.Transparency = Config.FovTransparency; FOV_Drawing.Visible = false

local Dot_Drawing = Drawing.new("Circle")
Dot_Drawing.Color = Color3.fromRGB(255, 255, 255); Dot_Drawing.Thickness = 1; Dot_Drawing.Radius = 3
Dot_Drawing.NumSides = 16; Dot_Drawing.Filled = true; Dot_Drawing.Transparency = 1; Dot_Drawing.Visible = false

local AuraVisual = Instance.new("CylinderHandleAdornment")
AuraVisual.Name = "WangAuraCircle"; AuraVisual.AlwaysOnTop = false; AuraVisual.ZIndex = 5

local Tracer_Cache = {}
local Character_Cache = {}
local NeckCache = {}

local function CreateTracerObject(Player)
    if Tracer_Cache[Player] then return end
    local Line = Drawing.new("Line")
    Line.Thickness = 1.2; Line.Color = Config.EspColor; Line.Transparency = 1; Line.Visible = false
    Tracer_Cache[Player] = Line
end

local function ClearTracerObject(Player)
    if Tracer_Cache[Player] then pcall(function() Tracer_Cache[Player].Visible = false Tracer_Cache[Player]:Remove() end) Tracer_Cache[Player] = nil end
end

local function CleanCharacterVisuals(Character)
    if not Character then return end
    if Character_Cache[Character] then
        pcall(function() Character_Cache[Character].Box.Visible = false Character_Cache[Character].Box:Remove() end)
        pcall(function() Character_Cache[Character].Gui:Destroy() end)
        Character_Cache[Character] = nil
    end
    local OldTag = Character:FindFirstChild("WangInfoTag", true)
    if OldTag then OldTag:Destroy() end
    local OldBox = Character:FindFirstChild("WangBoxFill", true)
    if OldBox then OldBox:Destroy() end
end

local function IsAlive(Character)
    if not Character or not Character.Parent then return false end
    local Hum = Character:FindFirstChildOfClass("Humanoid")
    if not Hum or Hum.Health <= 0 then return false end
    return true
end

local function IsTeammate(Player)
    if Player == LocalPlayer then return true end
    if Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then return true end
    if Player.TeamColor and LocalPlayer.TeamColor then
        if Player.TeamColor == LocalPlayer.TeamColor and Player.TeamColor.Name ~= "White" and Player.TeamColor.Name ~= "Medium stone grey" then return true end
    end
    local teamKeywords = {"Team", "Faction", "Gang", "Role", "Group", "Side"}
    for _, attr in pairs(teamKeywords) do
        local myAttr = LocalPlayer:GetAttribute(attr); local targetAttr = Player:GetAttribute(attr)
        if myAttr and targetAttr and myAttr == targetAttr then return true end
        if LocalPlayer.Character and Player.Character then
            local myCharAttr = LocalPlayer.Character:GetAttribute(attr); local targetCharAttr = Player.Character:GetAttribute(attr)
            if myCharAttr and targetCharAttr and myCharAttr == targetCharAttr then return true end
        end
    end
    local function CheckHiddenValues(parent1, parent2)
        if not parent1 or not parent2 then return false end
        for _, val in pairs(parent1:GetChildren()) do
            if val:IsA("StringValue") or val:IsA("IntValue") or val:IsA("ObjectValue") then
                for _, key in pairs(teamKeywords) do
                    if string.find(string.lower(val.Name), string.lower(key)) then
                        local targetVal = parent2:FindFirstChild(val.Name)
                        if targetVal and val.Value == targetVal.Value and val.Value ~= "" and val.Value ~= 0 then return true end
                    end
                end
            end
        end
        return false
    end
    if CheckHiddenValues(LocalPlayer, Player) then return true end
    if CheckHiddenValues(LocalPlayer.Character, Player.Character) then return true end
    return false
end

local function CheckWallOcclusion(TargetPart, Character)
    if not Config.WallCheck and not Config.AuraWallCheck then return true end
    local Origin = Camera.CFrame.Position; local Direction = TargetPart.Position - Origin
    local Params = RaycastParams.new(); Params.FilterType = Enum.RaycastFilterType.Exclude; Params.FilterDescendantsInstances = {LocalPlayer.Character, Character, Camera}
    return workspace:Raycast(Origin, Direction, Params) == nil
end

local function CheckTriggerWall(Position)
    if not Config.TriggerWallCheck then return true end
    local Origin = Camera.CFrame.Position; local Direction = Position - Origin
    local Params = RaycastParams.new(); Params.FilterType = Enum.RaycastFilterType.Exclude; Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local Result = workspace:Raycast(Origin, Direction, Params)
    return Result == nil or Result.Instance:IsDescendantOf(workspace)
end

local function GetDesiredHitbox(Character)
    if Config.TargetPart == "Head" then return Character:FindFirstChild("Head")
    elseif Config.TargetPart == "Torso" then return Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
    elseif Config.TargetPart == "Legs" then return Character:FindFirstChild("Right Leg") or Character:FindFirstChild("RightLowerLeg") or Character:FindFirstChild("Left Leg") or Character:FindFirstChild("LeftLowerLeg") or Character:FindFirstChild("HumanoidRootPart") end
    return Character:FindFirstChild("Head")
end

local function ToggleFlyState(state)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart; local hum = character:FindFirstChildOfClass("Humanoid")

    if state then
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        
        flyBodyGyro = Instance.new("BodyGyro"); flyBodyGyro.P = 9e4
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); flyBodyGyro.CFrame = root.CFrame; flyBodyGyro.Parent = root
        
        flyBodyVelocity = Instance.new("BodyVelocity"); flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9); flyBodyVelocity.Parent = root
        if hum then hum.PlatformStand = true end
    else
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        if hum then hum.PlatformStand = false end
    end
end

local function GetClosestPlayerToCrosshair()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local ClosestTarget = nil; local MaxDist = Config.FovRadius; local LowestHealth = math.huge

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and IsAlive(Player.Character) then
            if Config.TeamCheck and IsTeammate(Player) then continue end
            local TargetPartInstance = GetDesiredHitbox(Player.Character)
            local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if TargetPartInstance and Hum then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPartInstance.Position)
                if OnScreen and CheckWallOcclusion(TargetPartInstance, Player.Character) then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                    if Dist < Config.FovRadius then
                        if Config.PriorityLowestHealth then
                            if Hum.Health < LowestHealth then LowestHealth = Hum.Health ClosestTarget = TargetPartInstance end
                        else
                            if Dist < MaxDist then MaxDist = Dist ClosestTarget = TargetPartInstance end
                        end
                    end
                end
            end
        end
    end
    return ClosestTarget
end

local function GetAuraTarget()
    local MyChar = LocalPlayer.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end

    local BestTarget = nil; local LowestHealth = math.huge; local ClosestDist = Config.AuraRadius

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and IsAlive(Player.Character) then
            if Config.TeamCheckAura and IsTeammate(Player) then continue end
            local TargetPartInstance = GetDesiredHitbox(Player.Character)
            local EnemyRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
            
            if TargetPartInstance and EnemyRoot and Hum then
                if Config.AuraWallCheck and not CheckWallOcclusion(TargetPartInstance, Player.Character) then continue end
                local MyPosFlat = Vector3.new(MyRoot.Position.X, 0, MyRoot.Position.Z)
                local EnemyPosFlat = Vector3.new(EnemyRoot.Position.X, 0, EnemyRoot.Position.Z)
                local DistFlat = (EnemyPosFlat - MyPosFlat).Magnitude
                
                if DistFlat <= Config.AuraRadius then
                    if Config.PriorityLowestHealth then
                        if Hum.Health < LowestHealth then LowestHealth = Hum.Health BestTarget = TargetPartInstance end
                    else
                        if DistFlat < ClosestDist then ClosestDist = DistFlat BestTarget = TargetPartInstance end
                    end
                end
            end
        end
    end
    return BestTarget
end
local function GetPlayerColor(Player)
    if Config.EspTeamCheck and IsTeammate(Player) then return Color3.fromRGB(0, 255, 0) end
    return Config.EspColor
end

local function GetEquippedTool(Character)
    local Tool = Character:FindFirstChildOfClass("Tool")
    return Tool and Tool.Name or "None"
end

local function PerformTriggerbotClick()
    local TargetInstance = Mouse.Target
    if TargetInstance and TargetInstance.Parent then
        local Char = TargetInstance.Parent
        if Char:IsA("Accessory") then Char = Char.Parent end
        local Plr = Players:GetPlayerFromCharacter(Char)
        if Plr and Plr ~= LocalPlayer and IsAlive(Char) then
            if Config.TeamCheck and IsTeammate(Plr) then return end
            local TargetPart = GetDesiredHitbox(Char)
            if TargetPart and CheckTriggerWall(TargetPart.Position) then pcall(function() mouse1click() end) end
        end
    end
end

local IsFiring = false
local function ProcessAutoFarmPlayer()
    if not Config.AutoFarmPlayer then 
        if IsFiring then IsFiring = false pcall(function() mouse1release() end) end
        return 
    end
    local MyChar = LocalPlayer.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    if not MyRoot or not IsAlive(MyChar) then return end
    
    local Targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and IsAlive(p.Character) then
            if Config.TeamCheck and IsTeammate(p) then continue end
            local TRoot = p.Character:FindFirstChild("HumanoidRootPart")
            local THead = p.Character:FindFirstChild("Head")
            if TRoot and THead then table.insert(Targets, {Root = TRoot, Head = THead}) end
        end
    end
    if #Targets == 0 then if IsFiring then IsFiring = false pcall(function() mouse1release() end) end return end
    if CurrentFarmIndex > #Targets then CurrentFarmIndex = 1 end
    local ActiveTargetData = Targets[CurrentFarmIndex]
    local EnemyRoot = ActiveTargetData.Root; local EnemyHead = ActiveTargetData.Head
    
    if EnemyRoot and EnemyHead then
        local BehindPosition = EnemyRoot.Position - (EnemyRoot.CFrame.LookVector * 3)
        MyRoot.CFrame = CFrame.new(BehindPosition, EnemyRoot.Position)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, EnemyHead.Position)
        if not IsFiring then IsFiring = true pcall(function() mouse1press() end) end
        if tick() - LastFarmTime >= Config.AutoFarmDelay then LastFarmTime = tick() CurrentFarmIndex = CurrentFarmIndex + 1 end
    end
end

-- ==============================================================================
-- UI FRAMEWORK
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Wangcaos_Premium_Figma_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = SafeParent

local function MakeDraggable(UIElement, DragHandle, PosKey)
    local dragging = false; local dragInput, mousePos, framePos

    DragHandle.InputBegan:Connect(function(input)
        if Config.LockMobileButtons and PosKey then return end 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; mousePos = input.Position; framePos = UIElement.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                    if PosKey then
                        Config["MobilePos_"..PosKey.."_XS"] = UIElement.Position.X.Scale
                        Config["MobilePos_"..PosKey.."_XO"] = UIElement.Position.X.Offset
                        Config["MobilePos_"..PosKey.."_YS"] = UIElement.Position.Y.Scale
                        Config["MobilePos_"..PosKey.."_YO"] = UIElement.Position.Y.Offset
                    end
                end
            end)
        end
    end)
    DragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            UIElement.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

local function RegisterTouchFriendlyClick(TextButton, Callback)
    local HoldingTouch = false
    TextButton.MouseButton1Click:Connect(function() if not HoldingTouch then Callback() end end)
    TextButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then HoldingTouch = true end end)
    TextButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then if HoldingTouch then HoldingTouch = false Callback() end end end)
end

local function CreateIndependentMobileButton(Name, TextOn, TextOff, Key, ShowKey, DefaultColor, InitPos)
    local xs = Config["MobilePos_"..Key.."_XS"] or InitPos.X.Scale
    local xo = Config["MobilePos_"..Key.."_XO"] or InitPos.X.Offset
    local ys = Config["MobilePos_"..Key.."_YS"] or InitPos.Y.Scale
    local yo = Config["MobilePos_"..Key.."_YO"] or InitPos.Y.Offset
    
    if not Config["MobilePos_"..Key.."_XS"] then Config["MobilePos_"..Key.."_XS"] = xs; Config["MobilePos_"..Key.."_XO"] = xo; Config["MobilePos_"..Key.."_YS"] = ys; Config["MobilePos_"..Key.."_YO"] = yo end

    local ShortcutBtn = Instance.new("TextButton")
    ShortcutBtn.Name = "IndependentMobile_" .. Key
    ShortcutBtn.Parent = ScreenGui; ShortcutBtn.BackgroundColor3 = DefaultColor; ShortcutBtn.BackgroundTransparency = 0.2
    ShortcutBtn.Position = UDim2.new(xs, xo, ys, yo); ShortcutBtn.Size = UDim2.new(0, 52, 0, 52)
    ShortcutBtn.Font = Enum.Font.GothamBold; ShortcutBtn.Text = TextOff; ShortcutBtn.TextColor3 = Style_Text_Primary; ShortcutBtn.TextSize = 9
    ShortcutBtn.Visible = (Config[ShowKey] and IsMobile)
    Instance.new("UICorner", ShortcutBtn).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", ShortcutBtn)
    Stroke.Color = Style_Text_Primary; Stroke.Thickness = 1
    MakeDraggable(ShortcutBtn, ShortcutBtn, Key)
    GlobalMobileButtons[Key] = { Btn = ShortcutBtn, ShowKey = ShowKey }
    return ShortcutBtn
end

local MobAim = CreateIndependentMobileButton("Aimbot", "AIM\nON", "AIM\nOFF", "Aimbot", "ShowMobileAim", Color3.fromRGB(255, 50, 50), UDim2.new(0.85, 0, 0.15, 0))
local MobTrig = CreateIndependentMobileButton("Triggerbot", "TRIG\nON", "TRIG\nOFF", "Triggerbot", "ShowMobileTrig", Color3.fromRGB(230, 125, 30), UDim2.new(0.85, 0, 0.26, 0))
local MobSpeed = CreateIndependentMobileButton("Speed", "SPD\nON", "SPD\nOFF", "SpeedToggle", "ShowMobileSpeed", Color3.fromRGB(140, 30, 230), UDim2.new(0.85, 0, 0.37, 0))
local MobFarm = CreateIndependentMobileButton("AutoFarm", "FRM\nON", "FRM\nOFF", "AutoFarmPlayer", "ShowMobileFarm", Color3.fromRGB(45, 140, 75), UDim2.new(0.85, 0, 0.48, 0))
local MobAura = CreateIndependentMobileButton("Aura", "AUR\nON", "AUR\nOFF", "Aura", "ShowMobileAura", Color3.fromRGB(0, 150, 255), UDim2.new(0.85, 0, 0.59, 0))
local MobTP = CreateIndependentMobileButton("ThirdPerson", "3RD\nON", "3RD\nOFF", "ThirdPerson", "ShowMobileTP", Style_Text_Secondary, UDim2.new(0.85, 0, 0.70, 0))
local MobFly = CreateIndependentMobileButton("Fly", "FLY\nON", "FLY\nOFF", "Fly", "ShowMobileFly", Color3.fromRGB(0, 255, 255), UDim2.new(0.85, 0, 0.81, 0))

local lxs = Config["MobilePos_MainLogo_XS"] or 0
local lxo = Config["MobilePos_MainLogo_XO"] or 20
local lys = Config["MobilePos_MainLogo_YS"] or 0
local lyo = Config["MobilePos_MainLogo_YO"] or 20
if not Config["MobilePos_MainLogo_XS"] then Config["MobilePos_MainLogo_XS"] = lxs Config["MobilePos_MainLogo_XO"] = lxo Config["MobilePos_MainLogo_YS"] = lys Config["MobilePos_MainLogo_YO"] = lyo end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "PremiumToggleLogo"
ToggleButton.Parent = ScreenGui; ToggleButton.BackgroundColor3 = Style_SubBg; ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Position = UDim2.new(lxs, lxo, lys, lyo); ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold; ToggleButton.Text = "W"; ToggleButton.TextColor3 = Style_Text_Primary; ToggleButton.TextSize = 20
Instance.new("UICorner", ToggleButton).CornerRadius = Style_CornerRadius
local TogStroke = Instance.new("UIStroke", ToggleButton)
TogStroke.Color = Color3.fromRGB(60, 60, 60); TogStroke.Thickness = 1
ToggleButton.Visible = IsMobile
GlobalMobileButtons["MainLogo"] = { Btn = ToggleButton }
MakeDraggable(ToggleButton, ToggleButton, "MainLogo")
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Style_Bg
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300) 
MainFrame.ClipsDescendants = true
MainFrame.Visible = Config.MenuVisible
Instance.new("UICorner", MainFrame).CornerRadius = Style_CornerRadius
local MFrameStroke = Instance.new("UIStroke", MainFrame)
MFrameStroke.Color = Color3.fromRGB(45, 47, 50)
MFrameStroke.Thickness = 1

local CustomBackgroundImage = Instance.new("ImageLabel")
CustomBackgroundImage.Name = "MenuCustomWallpaper"
CustomBackgroundImage.Parent = MainFrame
CustomBackgroundImage.BackgroundTransparency = 1
CustomBackgroundImage.Size = UDim2.new(1, 0, 1, 0)
CustomBackgroundImage.Image = Config.BackgroundAssetId
CustomBackgroundImage.ImageTransparency = 0.75 
CustomBackgroundImage.ScaleType = Enum.ScaleType.Crop
CustomBackgroundImage.ZIndex = 0
CustomBackgroundImage.Visible = Config.CustomBackground
Instance.new("UICorner", CustomBackgroundImage).CornerRadius = Style_CornerRadius

local SettingsPanel = Instance.new("Frame")
SettingsPanel.Name = "SettingsPanel"
SettingsPanel.Parent = MainFrame
SettingsPanel.Position = UDim2.new(0, 0, 0, 0) 
SettingsPanel.Size = UDim2.new(1, 0, 1, 0) 
SettingsPanel.BackgroundTransparency = 1

local TopNavBar = Instance.new("Frame")
TopNavBar.Parent = SettingsPanel
TopNavBar.BackgroundColor3 = Style_Bg
TopNavBar.BackgroundTransparency = 0 
TopNavBar.Position = UDim2.new(0, 0, 0, 10)
TopNavBar.Size = UDim2.new(1, -10, 0, 42)
TopNavBar.ZIndex = 2
Instance.new("UICorner", TopNavBar).CornerRadius = Style_CornerRadius

local TabMenuContainer = Instance.new("Frame")
TabMenuContainer.Parent = TopNavBar
TabMenuContainer.BackgroundTransparency = 1
TabMenuContainer.Size = UDim2.new(1, -40, 1, 0)
local TabLayout = Instance.new("UIListLayout", TabMenuContainer)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
local TabPad = Instance.new("UIPadding", TabMenuContainer)
TabPad.PaddingLeft = UDim.new(0, 6)
TabPad.PaddingTop = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopNavBar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -30, 0.5, -13)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Style_Text_Secondary
CloseBtn.TextSize = 22

MakeDraggable(MainFrame, TopNavBar, nil) 
RegisterTouchFriendlyClick(CloseBtn, function() Config.MenuVisible = false MainFrame.Visible = false end)
RegisterTouchFriendlyClick(ToggleButton, function() Config.MenuVisible = not Config.MenuVisible MainFrame.Visible = Config.MenuVisible end)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = SettingsPanel
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 0, 0, 60)
ContentContainer.Size = UDim2.new(1, -5, 1, -70)
ContentContainer.ZIndex = 2

local CombatPage = Instance.new("ScrollingFrame", ContentContainer)
local PlayerPage = Instance.new("ScrollingFrame", ContentContainer)
local MovementPage = Instance.new("ScrollingFrame", ContentContainer)
local VisualPage = Instance.new("ScrollingFrame", ContentContainer)
local MiscPage = Instance.new("ScrollingFrame", ContentContainer)
local CreditsPage = Instance.new("ScrollingFrame", ContentContainer)

for _, page in pairs({CombatPage, PlayerPage, MovementPage, VisualPage, MiscPage, CreditsPage}) do
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y 
    page.CanvasSize = UDim2.new(0, 0, 0, 0) 
    page.ScrollBarThickness = 1 
    page.ScrollBarImageColor3 = Style_Inactive
    page.Visible = false
    local listLayout = Instance.new("UIListLayout", page)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local pagePadding = Instance.new("UIPadding", page)
    pagePadding.PaddingLeft = UDim.new(0, 10)
    pagePadding.PaddingRight = UDim.new(0, 10)
    pagePadding.PaddingBottom = UDim.new(0, 20) 
end
CombatPage.Visible = true

local function CreateSectionTitle(Page, Text)
    local Title = Instance.new("TextLabel", Page)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = Text:upper()
    Title.TextColor3 = Style_Text_Primary
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UIPadding", Title).PaddingLeft = UDim.new(0, 4) 
    return Title
end

local function CreatePremiumTab(Name, IconText, Order, TargetPage)
    local TabBtn = Instance.new("TextButton", TabMenuContainer)
    TabBtn.BackgroundColor3 = Style_Bg 
    TabBtn.BackgroundTransparency = Order == 1 and 0 or 1
    TabBtn.Size = UDim2.new(0, 60, Order == 1 and 30 or 28) 
    TabBtn.Font = Order == 1 and Enum.Font.GothamBold or Style_Font
    TabBtn.LayoutOrder = Order
    TabBtn.Text = IconText 
    TabBtn.TextColor3 = Order == 1 and Style_Text_Primary or Style_Text_Secondary
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = Style_CornerRadius
    
    local TStroke = Instance.new("UIStroke", TabBtn)
    TStroke.Color = Color3.fromRGB(55, 57, 61)
    TStroke.Enabled = Order == 1 

    RegisterTouchFriendlyClick(TabBtn, function()
        for _, p in pairs({CombatPage, PlayerPage, MovementPage, VisualPage, MiscPage, CreditsPage}) do p.Visible = false end
        for _, btn in pairs(TabMenuContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Style_Bg; btn.BackgroundTransparency = 1
                btn.TextColor3 = Style_Text_Secondary; btn.Font = Style_Font
                btn.Size = UDim2.new(0, 60, 0, 28); btn.UIStroke.Enabled = false
            end
        end
        TabBtn.BackgroundColor3 = Style_Bg; TabBtn.BackgroundTransparency = 0
        TabBtn.TextColor3 = Style_Text_Primary; TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Size = UDim2.new(0, 60, 0, 30); TStroke.Enabled = true
        TargetPage.Visible = true
    end)
end

local function UpdateToggleVisual(Key)
    local TargetData = GlobalSyncToggles[Key]
    if not TargetData then return end
    local state = Config[Key]
    local Ball = TargetData.Ball; local SwitchBg = TargetData.SwitchBg
    
    TweenService:Create(Ball, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = state and UDim2.new(1, -13, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
    TweenService:Create(SwitchBg, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = state and Style_Accent or Style_Inactive}):Play()
    
    if GlobalMobileButtons[Key] then
        local MData = GlobalMobileButtons[Key]
        MData.Btn.BackgroundColor3 = state and Style_Accent or TargetData.DefMobColor
        if Key == "Aimbot" then MData.Btn.Text = state and "AIM\nON" or "AIM\nOFF"
        elseif Key == "Triggerbot" then MData.Btn.Text = state and "TRIG\nON" or "TRIG\nOFF"
        elseif Key == "SpeedToggle" then MData.Btn.Text = state and "SPD\nON" or "SPD\nOFF"
        elseif Key == "AutoFarmPlayer" then MData.Btn.Text = state and "FRM\nON" or "FRM\nOFF"
        elseif Key == "Aura" then MData.Btn.Text = state and "AUR\nON" or "AUR\nOFF"
        elseif Key == "ThirdPerson" then MData.Btn.Text = state and "3RD\nON" or "3RD\nOFF"
        elseif Key == "Fly" then MData.Btn.Text = state and "FLY\nON" or "FLY\nOFF" end
    end
end

local RestrictedKeys = { ShowMobileTP = true, ShowMobileAura = true, ShowMobileAim = true, ShowMobileTrig = true, ShowMobileSpeed = true, ShowMobileFarm = true, ShowMobileFly = true }

local function AddPremiumToggle(Page, LabelText, Key, Callback, DefMobColor, BindKey)
    local TFrame = Instance.new("Frame", Page)
    TFrame.BackgroundColor3 = Style_SubBg
    TFrame.BackgroundTransparency = 0.2
    TFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight)
    Instance.new("UICorner", TFrame).CornerRadius = Style_CornerRadius
    local TFrameStroke = Instance.new("UIStroke", TFrame)
    TFrameStroke.Color = Color3.fromRGB(35, 37, 40); TFrameStroke.Thickness = 0.5
    
    local Lbl = Instance.new("TextLabel", TFrame)
    Lbl.BackgroundTransparency = 1
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Size = UDim2.new(1, -60, 1, 0) 
    Lbl.Font = Style_Font
    Lbl.Text = LabelText
    Lbl.TextColor3 = Style_Text_Primary
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBg = Instance.new("Frame", TFrame)
    SwitchBg.BackgroundColor3 = Config[Key] and Style_Accent or Style_Inactive
    SwitchBg.Position = UDim2.new(1, -45, 0.5, -8) 
    SwitchBg.Size = UDim2.new(0, 32, 0, 16)
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local Ball = Instance.new("Frame", SwitchBg)
    Ball.BackgroundColor3 = Style_Text_Primary
    Ball.Position = Config[Key] and UDim2.new(1, -13, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    Ball.Size = UDim2.new(0, 12, 0, 12)
    Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)

    local Btn = Instance.new("TextButton", TFrame)
    Btn.BackgroundTransparency = 1
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.Text = ""

    GlobalSyncToggles[Key] = {Ball = Ball, SwitchBg = SwitchBg, DefMobColor = DefMobColor or Style_Inactive}
    RegisterTouchFriendlyClick(Btn, function() 
        if RestrictedKeys[Key] and not IsMobile then
            pcall(function() StarterGui:SetCore("SendNotification", {Title = "WANGCAOS", Text = "Button enable only for PE!", Duration = 3}) end)
            return
        end
        Config[Key] = not Config[Key] 
        UpdateToggleVisual(Key) 
        if Callback then Callback(Config[Key]) end 
    end)

    if BindKey then
        local BindBtn = Instance.new("TextButton", TFrame)
        BindBtn.BackgroundColor3 = Style_SubBg 
        BindBtn.Position = UDim2.new(1, -100, 0.5, -10)
        BindBtn.Size = UDim2.new(0, 45, 0, 20)
        BindBtn.Font = Enum.Font.GothamBold
        BindBtn.Text = Config[BindKey] and Config[BindKey].Name or "NONE"
        BindBtn.TextColor3 = Style_Text_Primary
        BindBtn.TextSize = 10
        Instance.new("UICorner", BindBtn).CornerRadius = Style_CornerRadius
        local BStroke = Instance.new("UIStroke", BindBtn)
        BStroke.Color = Color3.fromRGB(55, 57, 60); BStroke.Thickness = 0.5

        local Listening = false; local ListenConnection
        local function EndListening(NewKey)
            Listening = false
            if ListenConnection then ListenConnection:Disconnect() end
            if NewKey then Config[BindKey] = NewKey BindBtn.Text = NewKey.Name:upper() else BindBtn.Text = Config[BindKey] and Config[BindKey].Name or "NONE" end
            BindBtn.TextColor3 = Style_Text_Primary
        end
        RegisterTouchFriendlyClick(BindBtn, function()
            if Listening then return end
            Listening = true; BindBtn.Text = "..."; BindBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
            task.delay(5, function() if Listening then EndListening(nil) end end)
            ListenConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then EndListening(input.KeyCode) end
            end)
        end)
    end
    table.insert(UI_Refresh_Functions, function() UpdateToggleVisual(Key) end)
end

local function AddPremiumSlider(Page, LabelText, Min, Max, Key, Callback)
    local SFrame = Instance.new("Frame", Page)
    SFrame.BackgroundColor3 = Style_SubBg
    SFrame.BackgroundTransparency = 0.2
    SFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight)
    Instance.new("UICorner", SFrame).CornerRadius = Style_CornerRadius
    local SFrameStroke = Instance.new("UIStroke", SFrame)
    SFrameStroke.Color = Color3.fromRGB(35, 37, 40); SFrameStroke.Thickness = 0.5

    local Lbl = Instance.new("TextLabel", SFrame)
    Lbl.BackgroundTransparency = 1
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Size = UDim2.new(0.4, 0, 1, 0)
    Lbl.Font = Style_Font
    Lbl.Text = LabelText
    Lbl.TextColor3 = Style_Text_Secondary 
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("Frame", SFrame)
    Bar.BackgroundColor3 = Style_Inactive 
    Bar.BorderSizePixel = 0
    Bar.Position = UDim2.new(1, -160, 0.5, -2)
    Bar.Size = UDim2.new(0, 100, 0, 4) 
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Bar)
    Fill.BackgroundColor3 = Style_Accent 
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new((Config[Key] - Min) / (Max - Min), 0, 1, 0)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local SliderBall = Instance.new("Frame", Fill)
    SliderBall.BackgroundColor3 = Style_Text_Primary
    SliderBall.Position = UDim2.new(1, -4, 0.5, -4)
    SliderBall.Size = UDim2.new(0, 8, 0, 8) 
    Instance.new("UICorner", SliderBall).CornerRadius = UDim.new(1, 0)

    local ValTxt = Instance.new("TextLabel", SFrame)
    ValTxt.BackgroundTransparency = 1
    ValTxt.Position = UDim2.new(1, -50, 0, 0)
    ValTxt.Size = UDim2.new(0, 40, 1, 0)
    ValTxt.Font = Enum.Font.GothamBold
    ValTxt.Text = tostring(Config[Key])
    ValTxt.TextColor3 = Style_Text_Primary
    ValTxt.TextSize = 11
    ValTxt.TextXAlignment = Enum.TextXAlignment.Right

    local Btn = Instance.new("TextButton", Bar)
    Btn.BackgroundTransparency = 1
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.Text = ""

    local Dragging = false
    local function Update(inputPos)
        local mouseX = (inputPos and inputPos.X) or Mouse.X
        local ratio = math.clamp((mouseX - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = Min + (Max - Min) * ratio
        if Max - Min > 10 then val = math.floor(val) else val = math.floor(val * 10) / 10 end
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        ValTxt.Text = tostring(val)
        Config[Key] = val
        if Callback then Callback(val) end
    end
    Btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = true Update(input.Position) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input.Position) end end)
    
    table.insert(UI_Refresh_Functions, function()
        ValTxt.Text = tostring(Config[Key])
        Fill.Size = UDim2.new((Config[Key] - Min) / (Max - Min), 0, 1, 0)
    end)
end

local function AddPremiumButton(Page, LabelText, ButtonText, Callback)
    local BFrame = Instance.new("Frame", Page)
    BFrame.BackgroundColor3 = Style_SubBg
    BFrame.BackgroundTransparency = 0.2
    BFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight)
    Instance.new("UICorner", BFrame).CornerRadius = Style_CornerRadius
    local BFrameStroke = Instance.new("UIStroke", BFrame)
    BFrameStroke.Color = Color3.fromRGB(35, 37, 40); BFrameStroke.Thickness = 0.5
    
    local Lbl = Instance.new("TextLabel", BFrame)
    Lbl.BackgroundTransparency = 1
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Font = Style_Font
    Lbl.Text = LabelText
    Lbl.TextColor3 = Style_Text_Primary
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ActionBtn = Instance.new("TextButton", BFrame)
    ActionBtn.BackgroundColor3 = Style_Accent 
    ActionBtn.Position = UDim2.new(1, -95, 0.5, -12)
    ActionBtn.Size = UDim2.new(0, 85, 0, 24)
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Text = ButtonText
    ActionBtn.TextColor3 = Style_Text_Primary
    ActionBtn.TextSize = 11
    Instance.new("UICorner", ActionBtn).CornerRadius = Style_CornerRadius
    RegisterTouchFriendlyClick(ActionBtn, Callback)
end

local function AddHitboxSelector(Page)
    local HFrame = Instance.new("Frame", Page)
    HFrame.BackgroundColor3 = Style_SubBg
    HFrame.BackgroundTransparency = 0.2
    HFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight)
    Instance.new("UICorner", HFrame).CornerRadius = Style_CornerRadius
    local HFrameStroke = Instance.new("UIStroke", HFrame)
    HFrameStroke.Color = Color3.fromRGB(35, 37, 40); HFrameStroke.Thickness = 0.5

    local Lbl = Instance.new("TextLabel", HFrame)
    Lbl.BackgroundTransparency = 1
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Font = Style_Font
    Lbl.Text = "Aimbot Target Hitbox"
    Lbl.TextColor3 = Style_Text_Primary
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local HitboxBtn = Instance.new("TextButton", HFrame)
    HitboxBtn.BackgroundColor3 = Style_SubBg 
    HitboxBtn.Position = UDim2.new(1, -95, 0.5, -12)
    HitboxBtn.Size = UDim2.new(0, 85, 0, 24)
    HitboxBtn.Font = Enum.Font.GothamBold
    HitboxBtn.Text = Config.TargetPart:upper()
    HitboxBtn.TextColor3 = Style_Text_Primary
    HitboxBtn.TextSize = 11
    Instance.new("UICorner", HitboxBtn).CornerRadius = Style_CornerRadius
    local HBStroke = Instance.new("UIStroke", HitboxBtn)
    HBStroke.Color = Color3.fromRGB(60, 62, 65); HBStroke.Thickness = 0.5 

    RegisterTouchFriendlyClick(HitboxBtn, function()
        if Config.TargetPart == "Head" then Config.TargetPart = "Torso" HitboxBtn.Text = "TORSO"
        elseif Config.TargetPart == "Torso" then Config.TargetPart = "Legs" HitboxBtn.Text = "LEGS"
        else Config.TargetPart = "Head" HitboxBtn.Text = "HEAD" end
    end)
    table.insert(UI_Refresh_Functions, function() HitboxBtn.Text = Config.TargetPart:upper() end)
end

local function AddSyncedEspColorSelector(Page)
    local CFrame = Instance.new("Frame", Page)
    CFrame.BackgroundColor3 = Style_SubBg
    CFrame.BackgroundTransparency = 0.2
    CFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight)
    Instance.new("UICorner", CFrame).CornerRadius = Style_CornerRadius
    local CFrameStroke = Instance.new("UIStroke", CFrame)
    CFrameStroke.Color = Color3.fromRGB(35, 37, 40); CFrameStroke.Thickness = 0.5

    local Lbl = Instance.new("TextLabel", CFrame)
    Lbl.BackgroundTransparency = 1
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Size = UDim2.new(0.6, 0, 1, 0)
    Lbl.Font = Style_Font
    Lbl.Text = "ESP & Tracer Color"
    Lbl.TextColor3 = Style_Text_Primary
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ColorBox = Instance.new("TextButton", CFrame)
    ColorBox.Name = "ColorBox"
    ColorBox.Position = UDim2.new(1, -35, 0.5, -9) 
    ColorBox.Size = UDim2.new(0, 25, 0, 18) 
    ColorBox.BackgroundColor3 = Config.EspColor
    ColorBox.Text = ""
    Instance.new("UICorner", ColorBox).CornerRadius = Style_CornerRadius
    local CBStroke = Instance.new("UIStroke", ColorBox)
    CBStroke.Color = Color3.fromRGB(55, 57, 60); CBStroke.Thickness = 0.5

    local palette = {Color3.fromRGB(255, 50, 50), Color3.fromRGB(0, 255, 100), Color3.fromRGB(255, 200, 0), Color3.fromRGB(230, 30, 230), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 255, 255)}
    local colorIdx = 1
    RegisterTouchFriendlyClick(ColorBox, function()
        colorIdx = (colorIdx % #palette) + 1
        Config.EspColor = palette[colorIdx]
        ColorBox.BackgroundColor3 = Config.EspColor
    end)
    table.insert(UI_Refresh_Functions, function() ColorBox.BackgroundColor3 = Config.EspColor end)
end

local function AddAuraColorSelector(Page)
    local CFrame = Instance.new("Frame", Page)
    CFrame.BackgroundColor3 = Style_SubBg
    CFrame.BackgroundTransparency = 0.2
    CFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight)
    Instance.new("UICorner", CFrame).CornerRadius = Style_CornerRadius
    local CFrameStroke = Instance.new("UIStroke", CFrame)
    CFrameStroke.Color = Color3.fromRGB(35, 37, 40); CFrameStroke.Thickness = 0.5

    local Lbl = Instance.new("TextLabel", CFrame)
    Lbl.BackgroundTransparency = 1
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Size = UDim2.new(0.6, 0, 1, 0)
    Lbl.Font = Style_Font
    Lbl.Text = "Aura Circle Color"
    Lbl.TextColor3 = Style_Text_Primary
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ColorBox = Instance.new("TextButton", CFrame)
    ColorBox.Name = "ColorBox"
    ColorBox.Position = UDim2.new(1, -35, 0.5, -9)
    ColorBox.Size = UDim2.new(0, 25, 0, 18) 
    ColorBox.BackgroundColor3 = Config.AuraColor
    ColorBox.Text = ""
    Instance.new("UICorner", ColorBox).CornerRadius = Style_CornerRadius
    local CBStroke = Instance.new("UIStroke", ColorBox)
    CBStroke.Color = Color3.fromRGB(55, 57, 60); CBStroke.Thickness = 0.5

    local palette = {Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 50, 50), Color3.fromRGB(0, 255, 100), Color3.fromRGB(255, 200, 0), Color3.fromRGB(230, 30, 230)}
    local colorIdx = 1
    RegisterTouchFriendlyClick(ColorBox, function()
        colorIdx = (colorIdx % #palette) + 1
        Config.AuraColor = palette[colorIdx]
        ColorBox.BackgroundColor3 = Config.AuraColor
    end)
    table.insert(UI_Refresh_Functions, function() ColorBox.BackgroundColor3 = Config.AuraColor end)
end

local function AddTracerModeSelector(Page)
    local MFrame = Instance.new("Frame", Page)
    MFrame.BackgroundColor3 = Style_SubBg
    MFrame.BackgroundTransparency = 0.2
    MFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight)
    Instance.new("UICorner", MFrame).CornerRadius = Style_CornerRadius
    local MFrameStroke = Instance.new("UIStroke", MFrame)
    MFrameStroke.Color = Color3.fromRGB(35, 37, 40); MFrameStroke.Thickness = 0.5

    local Lbl = Instance.new("TextLabel", MFrame)
    Lbl.BackgroundTransparency = 1
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Font = Style_Font
    Lbl.Text = "Tracer Origin Mode"
    Lbl.TextColor3 = Style_Text_Primary
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ModeBtn = Instance.new("TextButton", MFrame)
    ModeBtn.BackgroundColor3 = Style_SubBg 
    ModeBtn.Position = UDim2.new(1, -95, 0.5, -12)
    ModeBtn.Size = UDim2.new(0, 85, 0, 24)
    ModeBtn.Font = Enum.Font.GothamBold
    ModeBtn.Text = Config.TracerMode:upper()
    ModeBtn.TextColor3 = Style_Text_Primary
    ModeBtn.TextSize = 11
    Instance.new("UICorner", ModeBtn).CornerRadius = Style_CornerRadius
    local MBStroke = Instance.new("UIStroke", ModeBtn)
    MBStroke.Color = Color3.fromRGB(60, 62, 65); MBStroke.Thickness = 0.5 

    RegisterTouchFriendlyClick(ModeBtn, function()
        Config.TracerMode = Config.TracerMode == "Bottom" and "Center" or "Bottom"
        ModeBtn.Text = Config.TracerMode:upper()
    end)
    table.insert(UI_Refresh_Functions, function() ModeBtn.Text = Config.TracerMode:upper() end)
end

local function AddExportBox(Page)
    local TFrame = Instance.new("Frame", Page)
    TFrame.BackgroundColor3 = Style_SubBg
    TFrame.BackgroundTransparency = 0.2
    TFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight + 4) 
    Instance.new("UICorner", TFrame).CornerRadius = Style_CornerRadius
    local TFrameStroke = Instance.new("UIStroke", TFrame)
    TFrameStroke.Color = Color3.fromRGB(35, 37, 40); TFrameStroke.Thickness = 0.5

    local Box = Instance.new("TextBox", TFrame)
    Box.BackgroundTransparency = 1 
    Box.BackgroundColor3 = Style_SubBg
    Box.Position = UDim2.new(0, 10, 0.5, -12)
    Box.Size = UDim2.new(1, -85, 0, 24) 
    Box.Font = Style_Font
    Box.Text = ""
    Box.PlaceholderText = "Exported Code Here"
    Box.TextColor3 = Style_Text_Secondary
    Box.TextSize = 10
    Box.ClearTextOnFocus = false
    Instance.new("UICorner", Box).CornerRadius = Style_CornerRadius
    local BxStroke = Instance.new("UIStroke", Box)
    BxStroke.Color = Color3.fromRGB(55, 57, 60); BxStroke.Thickness = 0.5 

    local ActionBtn = Instance.new("TextButton", TFrame)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(30, 140, 230) 
    ActionBtn.Position = UDim2.new(1, -70, 0.5, -12)
    ActionBtn.Size = UDim2.new(0, 60, 0, 24)
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Text = "EXPORT"
    ActionBtn.TextColor3 = Style_Text_Primary
    ActionBtn.TextSize = 10
    Instance.new("UICorner", ActionBtn).CornerRadius = Style_CornerRadius

    RegisterTouchFriendlyClick(ActionBtn, function()
        local code = ExportSettings()
        Box.Text = code
        if setclipboard then
            setclipboard(code)
            StarterGui:SetCore("SendNotification", {Title = "WANGCAOS", Text = "Code copied to clipboard!", Duration = 3})
        else
            StarterGui:SetCore("SendNotification", {Title = "WANGCAOS", Text = "Please copy from the text box!", Duration = 3})
        end
    end)
end

local function AddImportBox(Page)
    local TFrame = Instance.new("Frame", Page)
    TFrame.BackgroundColor3 = Style_SubBg
    TFrame.BackgroundTransparency = 0.2
    TFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight + 4) 
    Instance.new("UICorner", TFrame).CornerRadius = Style_CornerRadius
    local TFrameStroke = Instance.new("UIStroke", TFrame)
    TFrameStroke.Color = Color3.fromRGB(35, 37, 40); TFrameStroke.Thickness = 0.5

    local Box = Instance.new("TextBox", TFrame)
    Box.BackgroundTransparency = 1 
    Box.BackgroundColor3 = Style_SubBg
    Box.Position = UDim2.new(0, 10, 0.5, -12)
    Box.Size = UDim2.new(1, -85, 0, 24)
    Box.Font = Style_Font
    Box.Text = ""
    Box.PlaceholderText = "Paste Code Here"
    Box.TextColor3 = Style_Text_Primary 
    Box.TextSize = 10
    Box.ClearTextOnFocus = false
    Instance.new("UICorner", Box).CornerRadius = Style_CornerRadius
    local BxStroke = Instance.new("UIStroke", Box)
    BxStroke.Color = Color3.fromRGB(55, 57, 60); BxStroke.Thickness = 0.5 

    local ActionBtn = Instance.new("TextButton", TFrame)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(45, 140, 75) 
    ActionBtn.Position = UDim2.new(1, -70, 0.5, -12)
    ActionBtn.Size = UDim2.new(0, 60, 0, 24)
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.Text = "IMPORT"
    ActionBtn.TextColor3 = Style_Text_Primary
    ActionBtn.TextSize = 10
    Instance.new("UICorner", ActionBtn).CornerRadius = Style_CornerRadius

    RegisterTouchFriendlyClick(ActionBtn, function()
        local code = Box.Text
        if code and code ~= "" then
            local success = ImportSettings(code)
            if success then
                StarterGui:SetCore("SendNotification", {Title = "WANGCAOS", Text = "Import Success!\nInterface updated.", Duration = 3})
                Box.Text = ""
            else
                StarterGui:SetCore("SendNotification", {Title = "WANGCAOS", Text = "Invalid Code!", Duration = 3})
            end
        end
    end)
end

local function AddPremiumCreditBox(Page, Title, Description)
    local CFrame = Instance.new("Frame", Page)
    CFrame.BackgroundColor3 = Style_SubBg 
    CFrame.BackgroundTransparency = 0.2
    CFrame.Size = UDim2.new(1, 0, 0, Style_ElementHeight + 6) 
    Instance.new("UICorner", CFrame).CornerRadius = Style_CornerRadius
    local CFrameStroke = Instance.new("UIStroke", CFrame)
    CFrameStroke.Color = Color3.fromRGB(50, 52, 56); CFrameStroke.Thickness = 0.5 

    local TitleLbl = Instance.new("TextLabel", CFrame)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position = UDim2.new(0, 10, 0, 4)
    TitleLbl.Size = UDim2.new(1, -20, 0, 16)
    TitleLbl.Font = Enum.Font.GothamBold 
    TitleLbl.Text = Title
    TitleLbl.TextColor3 = Style_Text_Primary
    TitleLbl.TextSize = 11
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local DescLbl = Instance.new("TextLabel", CFrame)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Position = UDim2.new(0, 10, 0, 20)
    DescLbl.Size = UDim2.new(1, -20, 0, 16)
    DescLbl.Font = Style_Font
    DescLbl.Text = Description
    DescLbl.TextColor3 = Style_Text_Secondary 
    DescLbl.TextSize = 10
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
end
-- ==============================================================================
-- POPULATE Re-styled UI PAGES WITH SECTIONS AND CONTROLS
-- ==============================================================================

-- --- COMBAT PAGE ---
CreateSectionTitle(CombatPage, "Aim Assist Bot")
AddPremiumToggle(CombatPage, "Enable Aimbot Lock", "Aimbot", nil, Color3.fromRGB(255, 50, 50), "AimbotKeybind") 
AddPremiumToggle(CombatPage, "Aimbot Team Guard", "TeamCheck")
AddPremiumToggle(CombatPage, "Aimbot Wall Occlusion", "WallCheck")
AddPremiumSlider(CombatPage, "Aimbot Smoothness Factor", 0, 10, "Smoothness")
AddHitboxSelector(CombatPage)

CreateSectionTitle(CombatPage, "Character Kill Aura")
AddPremiumToggle(CombatPage, "Enable Kill Aura", "Aura", nil, Color3.fromRGB(0, 150, 255), "AuraKeybind")
AddPremiumToggle(CombatPage, "Aura Team Guard", "TeamCheckAura")
AddPremiumToggle(CombatPage, "Aura Wall Occlusion", "AuraWallCheck")
AddPremiumSlider(CombatPage, "Aura Field Radius", 5, 150, "AuraRadius")
AddPremiumSlider(CombatPage, "Aura Smoothness Factor", 0, 10, "AuraSmoothness")
AddPremiumSlider(CombatPage, "Aura Transparency (%)", 0, 100, "AuraTransparency")
AddAuraColorSelector(CombatPage)
AddPremiumToggle(CombatPage, "Priority Lowest Health", "PriorityLowestHealth")

CreateSectionTitle(CombatPage, "Automatic Triggerbot")
AddPremiumToggle(CombatPage, "Triggerbot Click Engine", "Triggerbot", nil, Color3.fromRGB(230, 125, 30), "TriggerbotKeybind")
AddPremiumToggle(CombatPage, "Triggerbot Wall Check", "TriggerWallCheck")

-- --- PLAYER PAGE ---
CreateSectionTitle(PlayerPage, "Character Modifications")
AddPremiumToggle(PlayerPage, "Enable Character Head Bow", "BowDown", nil, nil, nil)
AddPremiumSlider(PlayerPage, "Head Bow Angle Degree", 0, 90, "BowAngle")
AddPremiumToggle(PlayerPage, "Enable Spinbot Axis", "Spinbot", nil, nil, "SpinbotKeybind")
AddPremiumSlider(PlayerPage, "Spinbot Rotate Velocity", 5, 100, "SpinSpeed")

CreateSectionTitle(PlayerPage, "Exploitation Tools")
AddPremiumToggle(PlayerPage, "Auto Farm Player (Behind)", "AutoFarmPlayer", nil, Color3.fromRGB(45, 140, 75))
AddPremiumSlider(PlayerPage, "Farm TP Intervallic Delay", 0.01, 5, "AutoFarmDelay")
AddPremiumToggle(PlayerPage, "FullBright Atmosphere", "FullBright", function(state)
    if state then Lighting.Ambient = Color3.fromRGB(255, 255, 255) Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else Lighting.Ambient = Config.StoredAmbient Lighting.OutdoorAmbient = Config.StoredOutdoorAmbient end
end)

-- --- MOVEMENT PAGE ---
CreateSectionTitle(MovementPage, "Character Flight")
AddPremiumToggle(MovementPage, "Enable Flight Hack", "Fly", ToggleFlyState, Color3.fromRGB(0, 255, 255), "FlyKeybind")
AddPremiumSlider(MovementPage, "Flight Speed Velocity", 10, 300, "FlySpeed")

CreateSectionTitle(MovementPage, "Character Enhancements")
AddPremiumToggle(MovementPage, "WalkSpeed Safe Bypass", "SpeedToggle", nil, Color3.fromRGB(140, 30, 230), "SpeedKeybind")
AddPremiumSlider(MovementPage, "Speed Core Value", 16, 200, "WalkSpeed")
AddPremiumToggle(MovementPage, "JumpPower Boost Axis", "JumpToggle", nil, nil, "JumpKeybind")
AddPremiumSlider(MovementPage, "Jump Force Magnitude", 50, 350, "JumpPower")

-- --- VISUAL PAGE ---
CreateSectionTitle(VisualPage, "Character ESP")
AddPremiumToggle(VisualPage, "Master ESP Overlay Control", "EspMaster", nil, Color3.fromRGB(30, 140, 230), "EspMasterKeybind")
AddPremiumToggle(VisualPage, "ESP Team Guard (Green)", "EspTeamCheck")
AddPremiumToggle(VisualPage, "Render 2D ESP Box", "EspBox")
AddPremiumSlider(VisualPage, "ESP Opacity Multiplier", 0, 100, "EspTransparency")
AddPremiumToggle(VisualPage, "Snapline Tracers Vector", "EspTracer")
AddTracerModeSelector(VisualPage)
AddSyncedEspColorSelector(VisualPage)
AddPremiumToggle(VisualPage, "Informative Character Tags", "EspName")
AddPremiumToggle(VisualPage, "Show Character Health Meter", "EspHealth") 
AddPremiumSlider(VisualPage, "Max Rendering Vector Range", 100, 5000, "MaxDistance")

-- --- MISC PAGE ---
CreateSectionTitle(MiscPage, "Settings Management")
AddExportBox(MiscPage)
AddImportBox(MiscPage)

CreateSectionTitle(MiscPage, "Interface & Automation")
AddPremiumToggle(MiscPage, "Menu Modular Wallpaper", "CustomBackground", function(state) CustomBackgroundImage.Visible = state end)
AddPremiumToggle(MiscPage, "Draw Dynamic FOV Circle", "FovCircle")
AddPremiumSlider(MiscPage, "FOV Perimeter Range", 30, 500, "FovRadius")
AddPremiumToggle(MiscPage, "Force Third Person View", "ThirdPerson", nil, nil, nil)
AddPremiumSlider(MiscPage, "Third Person Distance", 5, 100, "ThirdPersonDist")
AddPremiumToggle(MiscPage, "Crosshair Center Alignment Dot", "CrosshairDot")
AddPremiumToggle(MiscPage, "Anti-AFK Auto Interactor", "AntiAFK", nil, Color3.fromRGB(210, 50, 140))

CreateSectionTitle(MiscPage, "Mobile Interface Controls")
AddPremiumToggle(MiscPage, "Lock Mobile Buttons Position", "LockMobileButtons", nil, Color3.fromRGB(200, 50, 50))
AddPremiumToggle(MiscPage, "Display Mobile Aim Trigger", "ShowMobileAim", function(state) GlobalMobileButtons["Aimbot"].Btn.Visible = (state and IsMobile) end)
AddPremiumToggle(MiscPage, "Display Mobile Aura Trigger", "ShowMobileAura", function(state) GlobalMobileButtons["Aura"].Btn.Visible = (state and IsMobile) end)
AddPremiumToggle(MiscPage, "Display Mobile Trigger Clicker", "ShowMobileTrig", function(state) GlobalMobileButtons["Triggerbot"].Btn.Visible = (state and IsMobile) end)
AddPremiumToggle(MiscPage, "Display Mobile Speed Toggle", "ShowMobileSpeed", function(state) GlobalMobileButtons["SpeedToggle"].Btn.Visible = (state and IsMobile) end)
AddPremiumToggle(MiscPage, "Display Mobile Farm Toggle", "ShowMobileFarm", function(state) GlobalMobileButtons["AutoFarmPlayer"].Btn.Visible = (state and IsMobile) end)
AddPremiumToggle(MiscPage, "Display Mobile Fly Toggle", "ShowMobileFly", function(state) GlobalMobileButtons["Fly"].Btn.Visible = (state and IsMobile) end)
AddPremiumToggle(MiscPage, "Display Mobile 3RD Button", "ShowMobileTP", function(state) GlobalMobileButtons["ThirdPerson"].Btn.Visible = (state and IsMobile) end)

CreateSectionTitle(MiscPage, "Process Control")
AddPremiumButton(MiscPage, "Uninject Execution Process", "UNINJECT NOW", function()
    MasterLoop:Disconnect()
    pcall(function() FOV_Drawing:Remove() end)
    pcall(function() Dot_Drawing:Remove() end)
    pcall(function() AuraVisual:Remove() end)
    pcall(function() mouse1release() end)
    ToggleFlyState(false)
    for _, L in pairs(Tracer_Cache) do pcall(function() L:Remove() end) end
    for C, Data in pairs(Character_Cache) do 
        pcall(function() Data.Box:Remove() end)
        CleanCharacterVisuals(C) 
    end
    for neck, origC0 in pairs(NeckCache) do if neck and neck.Parent then pcall(function() neck.C0 = origC0 end) end end
    LocalPlayer.CameraMinZoomDistance = 0.5
    LocalPlayer.CameraMaxZoomDistance = 400
    Lighting.Ambient = Config.StoredAmbient
    Lighting.OutdoorAmbient = Config.StoredOutdoorAmbient
    ScreenGui:Destroy()
end)

AddPremiumButton(MiscPage, "Join Community", "DISCORD", function()
    if setclipboard then setclipboard("Https://discord.gg/GkAKn4zzH") StarterGui:SetCore("SendNotification", {Title = "WANGCAOS", Text = "Copied Discord Link!", Duration = 3})
    else StarterGui:SetCore("SendNotification", {Title = "WANGCAOS", Text = "Https://discord.gg/GkAKn4zzH", Duration = 5}) end
end)

-- --- CREDIT PAGE ---
CreateSectionTitle(CreditsPage, "Architecture & Design")
AddPremiumCreditBox(CreditsPage, "Lead Architecture Designer", "Dai Ca Wang (Wangcaos Client Proprietor)")
CreateSectionTitle(CreditsPage, "Framework Information")
AddPremiumCreditBox(CreditsPage, "Framework Integrity Status", "Premium V6.9.4 - Compact GUI Edition")
CreateSectionTitle(CreditsPage, "Community")
AddPremiumCreditBox(CreditsPage, "Official Discord Community", "Https://discord.gg/GkAKn4zzH")

-- Create Re-styled tabs
CreatePremiumTab("⚔", "Combat", 1, CombatPage)
CreatePremiumTab("👤", "Player", 2, PlayerPage)
CreatePremiumTab("🏃", "Move", 3, MovementPage)
CreatePremiumTab("👁", "Visual", 4, VisualPage)
CreatePremiumTab("⚙", "Misc", 5, MiscPage)
CreatePremiumTab("👑", "Credit", 6, CreditsPage)
-- ==============================================================================
-- LOGIC & SERVICES SYNC
-- ==============================================================================

local function RegisterMobileClick(Btn, Key)
    RegisterTouchFriendlyClick(Btn, function() Config[Key] = not Config[Key] UpdateToggleVisual(Key) if Key == "Fly" then ToggleFlyState(Config.Fly) end end)
end
RegisterMobileClick(MobAim, "Aimbot"); RegisterMobileClick(MobTrig, "Triggerbot"); RegisterMobileClick(MobSpeed, "SpeedToggle")
RegisterMobileClick(MobFarm, "AutoFarmPlayer"); RegisterMobileClick(MobAura, "Aura"); RegisterMobileClick(MobTP, "ThirdPerson"); RegisterMobileClick(MobFly, "Fly")

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.MenuKeybind then Config.MenuVisible = not Config.MenuVisible MainFrame.Visible = Config.MenuVisible
    elseif input.KeyCode == Config.AimbotKeybind and Config.AimbotKeybind ~= Enum.KeyCode.Unknown then Config.Aimbot = not Config.Aimbot UpdateToggleVisual("Aimbot")
    elseif input.KeyCode == Config.AuraKeybind and Config.AuraKeybind ~= Enum.KeyCode.Unknown then Config.Aura = not Config.Aura UpdateToggleVisual("Aura")
    elseif input.KeyCode == Config.TriggerbotKeybind and Config.TriggerbotKeybind ~= Enum.KeyCode.Unknown then Config.Triggerbot = not Config.Triggerbot UpdateToggleVisual("Triggerbot")
    elseif input.KeyCode == Config.SpinbotKeybind and Config.SpinbotKeybind ~= Enum.KeyCode.Unknown then Config.Spinbot = not Config.Spinbot UpdateToggleVisual("Spinbot")
    elseif input.KeyCode == Config.EspMasterKeybind and Config.EspMasterKeybind ~= Enum.KeyCode.Unknown then Config.EspMaster = not Config.EspMaster UpdateToggleVisual("EspMaster")
    elseif input.KeyCode == Config.SpeedKeybind and Config.SpeedKeybind ~= Enum.KeyCode.Unknown then Config.SpeedToggle = not Config.SpeedToggle UpdateToggleVisual("SpeedToggle")
    elseif input.KeyCode == Config.JumpKeybind and Config.JumpKeybind ~= Enum.KeyCode.Unknown then Config.JumpToggle = not Config.JumpToggle UpdateToggleVisual("JumpToggle")
    elseif input.KeyCode == Config.FlyKeybind and Config.FlyKeybind ~= Enum.KeyCode.Unknown then Config.Fly = not Config.Fly UpdateToggleVisual("Fly") ToggleFlyState(Config.Fly) end
end)

pcall(function()
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
        end
    end)
end)

local function RenderVisuals(Player, Character)
    if not Character or not Character.Parent then return end
    local Root = Character:WaitForChild("HumanoidRootPart", 5); local Head = Character:WaitForChild("Head", 5)
    if not Root or not Head then return end
    
    CleanCharacterVisuals(Character)
    
    -- Using proper 2D Drawing for ESP Box instead of solid block highlight
    local Box = Drawing.new("Square")
    Box.Thickness = 1.5
    Box.Filled = false
    Box.Visible = false
    Box.ZIndex = 2

    local Gui = Instance.new("BillboardGui")
    Gui.Name = "WangInfoTag" Gui.Adornee = Head 
    Gui.Size = UDim2.new(0, 150, 0, 80) 
    Gui.StudsOffset = Vector3.new(0, 4, 0) Gui.AlwaysOnTop = true

    local Label = Instance.new("TextLabel", Gui)
    Label.Size = UDim2.new(1, 0, 0, 30) Label.BackgroundTransparency = 1 
    Label.Font = Enum.Font.Code 
    Label.TextSize = 12 Label.TextColor3 = Config.EspColor
    
    local HealthBG = Instance.new("Frame", Gui)
    HealthBG.Name = "HealthBG" HealthBG.BackgroundColor3 = Color3.fromRGB(40, 0, 0) HealthBG.BorderSizePixel = 0 
    HealthBG.Position = UDim2.new(0, 0, 0, 35) HealthBG.Size = UDim2.new(1, 0, 0, 3) HealthBG.Visible = false
    
    local HealthBar = Instance.new("Frame", HealthBG)
    HealthBar.Name = "HealthBar" HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100) 
    HealthBar.BorderSizePixel = 0 HealthBar.Size = UDim2.new(1, 0, 1, 0)

    -- Đã sửa Parent thành ScreenGui ở đây
    Gui.Parent = ScreenGui
    Character_Cache[Character] = { Box = Box, Gui = Gui, Label = Label, HealthBG = HealthBG, HealthBar = HealthBar, Player = Player }
end

local function MonitorPlayer(Player)
    if Player == LocalPlayer then return end
    Player.CharacterAdded:Connect(function(Char) task.spawn(RenderVisuals, Player, Char) end)
    if Player.Character then task.spawn(RenderVisuals, Player, Player.Character) end
end

-- ==============================================================================
-- MASTER RENDER STEPPED LOOP
-- ==============================================================================

MasterLoop = RunService.RenderStepped:Connect(function()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local ScreenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    
    if Config.FovCircle then FOV_Drawing.Position = ScreenCenter FOV_Drawing.Radius = Config.FovRadius FOV_Drawing.Visible = true else FOV_Drawing.Visible = false end
    if Config.CrosshairDot then Dot_Drawing.Position = ScreenCenter Dot_Drawing.Visible = true else Dot_Drawing.Visible = false end

    if Config.ThirdPerson then LocalPlayer.CameraMinZoomDistance = Config.ThirdPersonDist LocalPlayer.CameraMaxZoomDistance = Config.ThirdPersonDist
    else LocalPlayer.CameraMinZoomDistance = 0.5 LocalPlayer.CameraMaxZoomDistance = 400 end

    local MyChar = LocalPlayer.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    
    if IsAlive(MyChar) and MyRoot then
        local MyHum = MyChar:FindFirstChildOfClass("Humanoid")
        if MyHum then
            if Config.SpeedToggle then MyHum.WalkSpeed = Config.WalkSpeed end
            if Config.JumpToggle then MyHum.UseJumpPower = true MyHum.JumpPower = Config.JumpPower end
        end
        if Config.Spinbot then
            CurrentSpinAngle = (CurrentSpinAngle + Config.SpinSpeed) % 360
            MyRoot.CFrame = CFrame.new(MyRoot.CFrame.Position) * CFrame.Angles(0, math.rad(CurrentSpinAngle), 0)
        end
        
        if Config.Fly and flyBodyGyro and flyBodyVelocity then
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            
            if MyHum and MyHum.MoveDirection.Magnitude > 0 then
                local look = Camera.CFrame.LookVector; local right = Camera.CFrame.RightVector
                local flatLook = Vector3.new(look.X, 0, look.Z); local flatRight = Vector3.new(right.X, 0, right.Z)
                if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
                local forwardIntent = MyHum.MoveDirection:Dot(flatLook)
                local rightIntent = MyHum.MoveDirection:Dot(flatRight)
                if moveDir.Magnitude == 0 then moveDir = (look * forwardIntent) + (right * rightIntent) end
            end
            
            if moveDir.Magnitude > 0 then flyBodyVelocity.Velocity = moveDir.Unit * Config.FlySpeed else flyBodyVelocity.Velocity = Vector3.new(0, 0, 0) end
            flyBodyGyro.CFrame = Camera.CFrame
        end
        
        local headInstance = MyChar:FindFirstChild("Head")
        local torsoInstance = MyChar:FindFirstChild("UpperTorso") or MyChar:FindFirstChild("Torso")
        local neckJoint = (headInstance and headInstance:FindFirstChild("Neck")) or (torsoInstance and torsoInstance:FindFirstChild("Neck"))
        if neckJoint and neckJoint:IsA("Motor6D") then
            if not NeckCache[neckJoint] then NeckCache[neckJoint] = neckJoint.C0 end
            if Config.BowDown then neckJoint.C0 = NeckCache[neckJoint] * CFrame.Angles(math.rad(-Config.BowAngle), 0, 0) else neckJoint.C0 = NeckCache[neckJoint] end
        end
        
        if Config.Aura then
            if AuraVisual.Parent ~= MyRoot then AuraVisual.Parent = MyRoot AuraVisual.Adornee = MyRoot end
            AuraVisual.Height = 0.08 AuraVisual.Radius = Config.AuraRadius AuraVisual.Color3 = Config.AuraColor
            AuraVisual.Transparency = Config.AuraTransparency / 100 AuraVisual.CFrame = CFrame.new(0, -3.1, 0) * CFrame.Angles(math.rad(90), 0, 0) AuraVisual.Visible = true
        else AuraVisual.Visible = false end
    else AuraVisual.Visible = false end

    task.spawn(ProcessAutoFarmPlayer)
    if Config.Triggerbot then task.spawn(PerformTriggerbotClick) end

    local AuraActiveTarget = nil
    if Config.Aura then
        AuraActiveTarget = GetAuraTarget()
        if AuraActiveTarget then
            local LerpFactor = 1
            if Config.AuraSmoothness > 0 then LerpFactor = math.clamp(1 / (Config.AuraSmoothness * 3 + 1), 0.01, 1) end
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, AuraActiveTarget.Position), LerpFactor)
        end
    end

    if Config.Aimbot and not Config.AutoFarmPlayer and not AuraActiveTarget then
        local Target = GetClosestPlayerToCrosshair()
        if Target then
            local LerpFactor = 1
            if Config.Smoothness > 0 then LerpFactor = math.clamp(1 / (Config.Smoothness * 3 + 1), 0.01, 1) end
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Position), LerpFactor)
        end
    end

    for Char, Data in pairs(Character_Cache) do
        if Char and Char.Parent and IsAlive(Char) then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Head = Char:FindFirstChild("Head")
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            
            local isTarget = true 
            
            if Config.EspMaster and Root and Head and MyChar and MyChar:FindFirstChild("HumanoidRootPart") and Hum and isTarget then
                local PColor = GetPlayerColor(Data.Player)
                local Dist = math.floor((Root.Position - MyChar.HumanoidRootPart.Position).Magnitude)
                local RootPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

                -- 2D Box Logic Implementation
                -- Đã thêm kiểm tra logic chiều sâu Z ở đây!
                local HeadPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegPos = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))

                if Config.EspBox and Dist <= Config.MaxDistance and OnScreen and HeadPos.Z > 0 and LegPos.Z > 0 then 
                    local height = math.abs(HeadPos.Y - LegPos.Y)
                    local width = height / 2
                    Data.Box.Size = Vector2.new(width, height)
                    Data.Box.Position = Vector2.new(RootPos.X - width / 2, math.min(HeadPos.Y, LegPos.Y))
                    Data.Box.Color = PColor
                    Data.Box.Transparency = 1 - (Config.EspTransparency / 100)
                    Data.Box.Visible = true 
                else 
                    Data.Box.Visible = false 
                end

                if Config.EspName and Dist <= Config.MaxDistance then Data.Gui.Enabled = true Data.Label.Visible = true Data.Label.TextColor3 = PColor Data.Label.Text = string.format("%s (%dm)\\n[%s] [%s]", Data.Player.Name, Dist, Data.Player.Team and Data.Player.Team.Name or "No Team", GetEquippedTool(Char)) else Data.Label.Visible = false end
                if Config.EspHealth and Dist <= Config.MaxDistance then Data.Gui.Enabled = true Data.HealthBG.Visible = true local HealthPercent = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1) Data.HealthBar.Size = UDim2.new(HealthPercent, 0, 1, 0) Data.HealthBar.BackgroundColor3 = Color3.fromHSV(HealthPercent * 0.35, 1, 1) else Data.HealthBG.Visible = false end

                local Tracer = Tracer_Cache[Data.Player]
                if Tracer and Config.EspTracer and Dist <= Config.MaxDistance then
                    local Leg, IsTracerOnScreen = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
                    if IsTracerOnScreen then Tracer.From = Config.TracerMode == "Center" and ScreenCenter or ScreenBottom Tracer.To = Vector2.new(Leg.X, Leg.Y) Tracer.Color = PColor Tracer.Visible = true else Tracer.Visible = false end
                elseif Tracer then Tracer.Visible = false end
            else Data.Box.Visible = false Data.Label.Visible = false Data.HealthBG.Visible = false if Tracer_Cache[Data.Player] then Tracer_Cache[Data.Player].Visible = false end end
        else CleanCharacterVisuals(Char) Character_Cache[Char] = nil end
    end
end)

Players.PlayerAdded:Connect(function(Player) CreateTracerObject(Player) MonitorPlayer(Player) end)
Players.PlayerRemoving:Connect(function(Player) ClearTracerObject(Player) end)

for _, P in pairs(Players:GetPlayers()) do CreateTracerObject(P) MonitorPlayer(P) end
for K, _ in pairs(GlobalSyncToggles) do UpdateToggleVisual(K) end

pcall(function()
    StarterGui:SetCore("SendNotification", {Title = "WANGCAOS CLIENT V6.9.4", Text = "Loaded Modern Compact Edition (2D Box) successfully!", Duration = 5})
end)
-- ==============================================================================
-- END OF SCRIPT - MODERN COMPACT EDITION CREATED BY BE FOR DAI CA WANG (2026)
-- Design Integrity: Minimalism/Dark/Blur (Modern modern GUI)
-- ==============================================================================
