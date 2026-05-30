-- ==============================================================================
-- WANGCAOS PREMIUM CLIENT V7.8 - FULL FEATURES + COMPACT UI + AUTOSAVE + FLY
-- ALL RIGHTS RESERVED BY WANG (2026)
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

local ConfigFileName = "Wangcaos_Config_AutoSave.json"

local Config = {
    MenuVisible = true,
    MenuKeybind = Enum.KeyCode.RightShift,
    
    Aimbot = false,
    AimbotKeybind = Enum.KeyCode.E,
    TeamCheck = true,
    WallCheck = true,
    Smoothness = 5,
    TargetPart = "Head",
    
    Aura = false,
    AuraKeybind = Enum.KeyCode.H,
    TeamCheckAura = true,
    AuraWallCheck = true,
    AuraSmoothness = 5,
    AuraRadius = 30,
    AuraColor = Color3.fromRGB(0, 170, 255),
    AuraTransparency = 50,
    PriorityLowestHealth = false,
    
    Triggerbot = false,
    TriggerbotKeybind = Enum.KeyCode.T,
    TriggerWallCheck = true,
    
    Spinbot = false,
    SpinbotKeybind = Enum.KeyCode.K,
    SpinSpeed = 25,
    
    AutoFarmPlayer = false,
    AutoFarmDelay = 0.05,
    
    BowDown = false,
    BowAngle = 45,
    ThirdPerson = false,
    ThirdPersonDist = 15,
    AntiAFK = false,
    
    EspMaster = false,
    EspMasterKeybind = Enum.KeyCode.O,
    FovCircle = false,
    FovRadius = 120,
    FovThickness = 1.5,
    FovSides = 64,
    FovColor = Color3.fromRGB(255, 255, 255),
    FovTransparency = 0.8,
    FovFilled = false,
    
    CrosshairDot = false,
    EspBox = false,
    EspTracer = false,
    TracerMode = "Bottom",
    EspColor = Color3.fromRGB(255, 50, 50),
    EspName = false,
    EspHealth = false,
    EspTransparency = 80,
    MaxDistance = 5000,
    
    SpeedToggle = false,
    SpeedKeybind = Enum.KeyCode.Q,
    WalkSpeed = 16,
    JumpToggle = false,
    JumpKeybind = Enum.KeyCode.G,
    JumpPower = 50,
    
    FlyToggle = false,
    FlySpeed = 50,
    FlyKeybind = Enum.KeyCode.F,
    
    FullBright = false,
    
    ShowMobileAim = false,
    ShowMobileTrig = false,
    ShowMobileSpeed = false,
    ShowMobileFarm = false,
    ShowMobileAura = false,
    ShowMobileTP = false,
    ShowMobileFly = false,
    LockMobileButtons = false,
    
    StoredAmbient = Lighting.Ambient,
    StoredOutdoorAmbient = Lighting.OutdoorAmbient
}

local UI_Refresh_Functions = {}
local GlobalMobileButtons = {}
local GlobalSyncToggles = {}

local function LoadConfigFromFile()
    pcall(function()
        if readfile and isfile and isfile(ConfigFileName) then
            local json = readfile(ConfigFileName)
            local importTable = HttpService:JSONDecode(json)
            for k, v in pairs(importTable) do
                if type(v) == "table" and v.__type then
                    if v.__type == "EnumItem" then
                        local enumType = string.split(v.EnumType, ".")[3] or v.EnumType
                        pcall(function() Config[k] = Enum[enumType][v.Name] end)
                    elseif v.__type == "Color3" then
                        Config[k] = Color3.new(v.R, v.G, v.B)
                    end
                else
                    Config[k] = v
                end
            end
        end
    end)
end
LoadConfigFromFile()

local function SaveConfigToFile()
    pcall(function()
        if writefile then
            local exportTable = {}
            for k, v in pairs(Config) do
                if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                    exportTable[k] = v
                elseif typeof(v) == "EnumItem" then
                    exportTable[k] = {__type = "EnumItem", EnumType = tostring(v.EnumType), Name = v.Name}
                elseif typeof(v) == "Color3" then
                    exportTable[k] = {__type = "Color3", R = v.R, G = v.G, B = v.B}
                end
            end
            writefile(ConfigFileName, HttpService:JSONEncode(exportTable))
        end
    end)
end

local CurrentSpinAngle = 0
local IsMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
local LastFarmTime = 0
local CurrentFarmIndex = 1

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
    if old.Name == "Wangcaos_Compact_Figma_UI" then old:Destroy() end
end
local FOV_Drawing = Drawing.new("Circle")
FOV_Drawing.Color = Config.FovColor
FOV_Drawing.Thickness = Config.FovThickness
FOV_Drawing.NumSides = Config.FovSides
FOV_Drawing.Filled = Config.FovFilled
FOV_Drawing.Transparency = Config.FovTransparency
FOV_Drawing.Visible = false

local Dot_Drawing = Drawing.new("Circle")
Dot_Drawing.Color = Color3.fromRGB(255, 255, 255)
Dot_Drawing.Thickness = 1
Dot_Drawing.Radius = 3
Dot_Drawing.NumSides = 16
Dot_Drawing.Filled = true
Dot_Drawing.Transparency = 1
Dot_Drawing.Visible = false

local AuraVisual = Instance.new("CylinderHandleAdornment")
AuraVisual.Name = "WangAuraCircle"
AuraVisual.AlwaysOnTop = false
AuraVisual.ZIndex = 5

local Tracer_Cache = {}
local Character_Cache = {}
local NeckCache = {}

local function CreateTracerObject(Player)
    if Tracer_Cache[Player] then return end
    local Line = Drawing.new("Line")
    Line.Thickness = 1.2
    Line.Color = Config.EspColor
    Line.Transparency = 1
    Line.Visible = false
    Tracer_Cache[Player] = Line
end

local function ClearTracerObject(Player)
    if Tracer_Cache[Player] then
        pcall(function() Tracer_Cache[Player].Visible = false Tracer_Cache[Player]:Remove() end)
        Tracer_Cache[Player] = nil
    end
end

local function CleanCharacterVisuals(Character)
    if not Character then return end
    local OldBox = Character:FindFirstChild("WangBoxFill", true)
    if OldBox then OldBox:Destroy() end
    local OldTag = Character:FindFirstChild("WangInfoTag", true)
    if OldTag then OldTag:Destroy() end
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
        local myAttr = LocalPlayer:GetAttribute(attr)
        local targetAttr = Player:GetAttribute(attr)
        if myAttr and targetAttr and myAttr == targetAttr then return true end
        if LocalPlayer.Character and Player.Character then
            local myCharAttr = LocalPlayer.Character:GetAttribute(attr)
            local targetCharAttr = Player.Character:GetAttribute(attr)
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
    local Origin = Camera.CFrame.Position
    local Direction = TargetPart.Position - Origin
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {LocalPlayer.Character, Character, Camera}
    local Result = workspace:Raycast(Origin, Direction, Params)
    return Result == nil
end

local function CheckTriggerWall(Position)
    if not Config.TriggerWallCheck then return true end
    local Origin = Camera.CFrame.Position
    local Direction = Position - Origin
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local Result = workspace:Raycast(Origin, Direction, Params)
    return Result == nil or Result.Instance:IsDescendantOf(workspace)
end

local function GetDesiredHitbox(Character)
    if Config.TargetPart == "Head" then
        return Character:FindFirstChild("Head")
    elseif Config.TargetPart == "Torso" then
        return Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
    elseif Config.TargetPart == "Legs" then
        return Character:FindFirstChild("Right Leg") or Character:FindFirstChild("RightLowerLeg") or Character:FindFirstChild("Left Leg") or Character:FindFirstChild("LeftLowerLeg") or Character:FindFirstChild("HumanoidRootPart")
    end
    return Character:FindFirstChild("Head")
end
local function GetClosestPlayerToCrosshair()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local ClosestTarget = nil
    local MaxDist = Config.FovRadius
    local LowestHealth = math.huge

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
                            if Hum.Health < LowestHealth then
                                LowestHealth = Hum.Health
                                ClosestTarget = TargetPartInstance
                            end
                        else
                            if Dist < MaxDist then
                                MaxDist = Dist
                                ClosestTarget = TargetPartInstance
                            end
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

    local BestTarget = nil
    local LowestHealth = math.huge
    local ClosestDist = Config.AuraRadius

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
                        if Hum.Health < LowestHealth then
                            LowestHealth = Hum.Health
                            BestTarget = TargetPartInstance
                        end
                    else
                        if DistFlat < ClosestDist then
                            ClosestDist = DistFlat
                            BestTarget = TargetPartInstance
                        end
                    end
                end
            end
        end
    end
    return BestTarget
end

local function GetPlayerColor(Player)
    return IsTeammate(Player) and Color3.fromRGB(0, 170, 255) or Config.EspColor
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
            if TargetPart and CheckTriggerWall(TargetPart.Position) then
                pcall(function() mouse1click() end)
            end
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
    
    if #Targets == 0 then 
        if IsFiring then IsFiring = false pcall(function() mouse1release() end) end
        return 
    end
    
    if CurrentFarmIndex > #Targets then CurrentFarmIndex = 1 end
    local ActiveTargetData = Targets[CurrentFarmIndex]
    local EnemyRoot = ActiveTargetData.Root
    local EnemyHead = ActiveTargetData.Head
    
    if EnemyRoot and EnemyHead then
        local BehindPosition = EnemyRoot.Position - (EnemyRoot.CFrame.LookVector * 3)
        MyRoot.CFrame = CFrame.new(BehindPosition, EnemyRoot.Position)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, EnemyHead.Position)
        
        if not IsFiring then
            IsFiring = true
            pcall(function() mouse1press() end)
        end
        
        if tick() - LastFarmTime >= Config.AutoFarmDelay then
            LastFarmTime = tick()
            CurrentFarmIndex = CurrentFarmIndex + 1
        end
    end
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Wangcaos_Compact_Figma_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = SafeParent

local function MakeDraggable(UIElement, DragHandle, PosKey)
    local dragging = false
    local dragInput, mousePos, framePos

    DragHandle.InputBegan:Connect(function(input)
        if Config.LockMobileButtons and PosKey then return end 
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = UIElement.Position
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
    TextButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if HoldingTouch then HoldingTouch = false Callback() end
        end
    end)
end

-- ==============================================================================
-- MOBILE BUTTONS (INDEPENDENT)
-- ==============================================================================
local function CreateIndependentMobileButton(Name, TextOn, TextOff, Key, ShowKey, DefaultColor, InitPos)
    local xs = Config["MobilePos_"..Key.."_XS"] or InitPos.X.Scale
    local xo = Config["MobilePos_"..Key.."_XO"] or InitPos.X.Offset
    local ys = Config["MobilePos_"..Key.."_YS"] or InitPos.Y.Scale
    local yo = Config["MobilePos_"..Key.."_YO"] or InitPos.Y.Offset
    
    if not Config["MobilePos_"..Key.."_XS"] then
        Config["MobilePos_"..Key.."_XS"] = xs
        Config["MobilePos_"..Key.."_XO"] = xo
        Config["MobilePos_"..Key.."_YS"] = ys
        Config["MobilePos_"..Key.."_YO"] = yo
    end

    local ShortcutBtn = Instance.new("TextButton")
    ShortcutBtn.Name = "IndependentMobile_" .. Key
    ShortcutBtn.Parent = ScreenGui
    ShortcutBtn.BackgroundColor3 = DefaultColor
    ShortcutBtn.BackgroundTransparency = 0.2
    ShortcutBtn.Position = UDim2.new(xs, xo, ys, yo)
    ShortcutBtn.Size = UDim2.new(0, 52, 0, 52)
    ShortcutBtn.Font = Enum.Font.GothamBold
    ShortcutBtn.Text = TextOff
    ShortcutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ShortcutBtn.TextSize = 9
    ShortcutBtn.Visible = (Config[ShowKey] and IsMobile)
    Instance.new("UICorner", ShortcutBtn).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", ShortcutBtn)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1.5
    MakeDraggable(ShortcutBtn, ShortcutBtn, Key)
    GlobalMobileButtons[Key] = { Btn = ShortcutBtn, ShowKey = ShowKey, DefColor = DefaultColor, T_ON = TextOn, T_OFF = TextOff }
    
    RegisterTouchFriendlyClick(ShortcutBtn, function()
        Config[Key] = not Config[Key]
        for _, refresh in pairs(UI_Refresh_Functions) do pcall(refresh) end
    end)
    return ShortcutBtn
end

CreateIndependentMobileButton("Aimbot", "AIM\nON", "AIM\nOFF", "Aimbot", "ShowMobileAim", Color3.fromRGB(255, 50, 50), UDim2.new(0.85, 0, 0.15, 0))
CreateIndependentMobileButton("Triggerbot", "TRIG\nON", "TRIG\nOFF", "Triggerbot", "ShowMobileTrig", Color3.fromRGB(230, 125, 30), UDim2.new(0.85, 0, 0.26, 0))
CreateIndependentMobileButton("Speed", "SPD\nON", "SPD\nOFF", "SpeedToggle", "ShowMobileSpeed", Color3.fromRGB(140, 30, 230), UDim2.new(0.85, 0, 0.37, 0))
CreateIndependentMobileButton("AutoFarm", "FRM\nON", "FRM\nOFF", "AutoFarmPlayer", "ShowMobileFarm", Color3.fromRGB(45, 140, 75), UDim2.new(0.85, 0, 0.48, 0))
CreateIndependentMobileButton("Aura", "AUR\nON", "AUR\nOFF", "Aura", "ShowMobileAura", Color3.fromRGB(0, 150, 255), UDim2.new(0.85, 0, 0.59, 0))
CreateIndependentMobileButton("ThirdPerson", "3RD\nON", "3RD\nOFF", "ThirdPerson", "ShowMobileTP", Color3.fromRGB(150, 150, 150), UDim2.new(0.85, 0, 0.70, 0))
CreateIndependentMobileButton("FlyToggle", "FLY\nON", "FLY\nOFF", "FlyToggle", "ShowMobileFly", Color3.fromRGB(200, 150, 50), UDim2.new(0.85, 0, 0.81, 0))

local lxs = Config["MobilePos_MainLogo_XS"] or 0
local lxo = Config["MobilePos_MainLogo_XO"] or 20
local lys = Config["MobilePos_MainLogo_YS"] or 0
local lyo = Config["MobilePos_MainLogo_YO"] or 20
if not Config["MobilePos_MainLogo_XS"] then
    Config["MobilePos_MainLogo_XS"] = lxs Config["MobilePos_MainLogo_XO"] = lxo Config["MobilePos_MainLogo_YS"] = lys Config["MobilePos_MainLogo_YO"] = lyo
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "PremiumToggleLogo"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Position = UDim2.new(lxs, lxo, lys, lyo)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "W"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", ToggleButton).Color = Color3.fromRGB(60, 60, 60)
Instance.new("UIStroke", ToggleButton).Thickness = 1.5

ToggleButton.Visible = IsMobile
GlobalMobileButtons["MainLogo"] = { Btn = ToggleButton }
MakeDraggable(ToggleButton, ToggleButton, "MainLogo")

-- ==============================================================================
-- COMPACT MENU GUI CONSTRUCTION
-- ==============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainCompactFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = Config.MenuVisible
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(45, 47, 50)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 6)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "WANGCAOS V7.8 | COMPACT"
TitleText.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.Code
TitleText.TextSize = 13
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar
RegisterTouchFriendlyClick(CloseBtn, function() Config.MenuVisible = false MainFrame.Visible = false end)
RegisterTouchFriendlyClick(ToggleButton, function() Config.MenuVisible = not Config.MenuVisible MainFrame.Visible = Config.MenuVisible end)
MakeDraggable(MainFrame, TitleBar, nil)

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(1, -10, 1, -40)
TabContainer.Position = UDim2.new(0, 5, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 2
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 1200)
TabContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = TabContainer

local function CreateSection(Name)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, 0, 0, 20)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = "  > " .. Name
    SectionLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Font = Enum.Font.Code
    SectionLabel.TextSize = 12
    SectionLabel.Parent = TabContainer
end

local function CreateToggle(Text, ConfigKey, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = TabContainer
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.Parent = ToggleFrame
    
    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 12, 0, 12)
    Checkbox.Position = UDim2.new(1, -22, 0.5, -6)
    Checkbox.BackgroundColor3 = Config[ConfigKey] and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 45)
    Checkbox.Text = ""
    Checkbox.Parent = ToggleFrame
    Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 3)
    
    RegisterTouchFriendlyClick(Checkbox, function()
        if ConfigKey == "LockMobileButtons" and not IsMobile then return end
        Config[ConfigKey] = not Config[ConfigKey]
        for _, refresh in pairs(UI_Refresh_Functions) do pcall(refresh) end
        if Callback then Callback(Config[ConfigKey]) end
    end)
    GlobalSyncToggles[ConfigKey] = Checkbox
end

local function CreateSlider(Text, ConfigKey, Min, Max, Decimals)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 32)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = TabContainer
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 16)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = Text .. ": " .. tostring(Config[ConfigKey])
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Code
    Label.TextSize = 11
    Label.Parent = SliderFrame
    
    local SliderBG = Instance.new("TextButton")
    SliderBG.Size = UDim2.new(1, -20, 0, 4)
    SliderBG.Position = UDim2.new(0, 10, 0, 20)
    SliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SliderBG.Text = ""
    SliderBG.AutoButtonColor = false
    SliderBG.Parent = SliderFrame
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(0, 2)
    
    local Fill = Instance.new("Frame")
    local fillWidth = (Config[ConfigKey] - Min) / (Max - Min)
    Fill.Size = UDim2.new(math.clamp(fillWidth, 0, 1), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBG
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)
    
    local Dragging = false
    local function Update(inputPos)
        local mouseX = (inputPos and inputPos.X) or Mouse.X
        local ratio = math.clamp((mouseX - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local val = Min + (Max - Min) * ratio
        if not Decimals then val = math.floor(val) else val = math.floor(val * 100) / 100 end
        Config[ConfigKey] = val
        for _, refresh in pairs(UI_Refresh_Functions) do pcall(refresh) end
    end
    SliderBG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = true Update(input.Position) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input.Position) end end)
    
    table.insert(UI_Refresh_Functions, function()
        Label.Text = Text .. ": " .. tostring(Config[ConfigKey])
        Fill.Size = UDim2.new((Config[ConfigKey] - Min) / (Max - Min), 0, 1, 0)
    end)
end

table.insert(UI_Refresh_Functions, function()
    for key, checkbox in pairs(GlobalSyncToggles) do
        if checkbox and Config[key] ~= nil then
            checkbox.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 45)
        end
    end
    for key, mData in pairs(GlobalMobileButtons) do
        if mData.Btn and Config[key] ~= nil then
            mData.Btn.BackgroundColor3 = Config[key] and Color3.fromRGB(45, 120, 75) or mData.DefColor
            mData.Btn.Text = Config[key] and mData.T_ON or mData.T_OFF
            mData.Btn.Visible = (Config[mData.ShowKey] and IsMobile)
        end
    end
end)

-- ==============================================================================
-- POPULATING THE COMPACT MENU
-- ==============================================================================
CreateSection("COMBAT & AIM")
CreateToggle("Enable Aimbot", "Aimbot")
CreateToggle("Aimbot Team Check", "TeamCheck")
CreateToggle("Aimbot Wall Check", "WallCheck")
CreateSlider("Aimbot Smoothness", "Smoothness", 0, 10, false)

CreateSection("AURA SYSTEM")
CreateToggle("Enable Kill Aura", "Aura")
CreateToggle("Aura Team Check", "TeamCheckAura")
CreateToggle("Aura Wall Check", "AuraWallCheck")
CreateToggle("Priority Lowest Health", "PriorityLowestHealth")
CreateSlider("Aura Radius", "AuraRadius", 5, 150, false)
CreateSlider("Aura Smoothness", "AuraSmoothness", 0, 10, false)
CreateSlider("Aura Transparency", "AuraTransparency", 0, 100, false)

CreateSection("TRIGGER & SPIN")
CreateToggle("Enable Triggerbot", "Triggerbot")
CreateToggle("Triggerbot Wall Check", "TriggerWallCheck")
CreateToggle("Enable Spinbot", "Spinbot")
CreateSlider("Spinbot Speed", "SpinSpeed", 5, 100, false)

CreateSection("PLAYER & MOVEMENT")
CreateToggle("Enable Speed Hack", "SpeedToggle")
CreateSlider("Walk Speed Value", "WalkSpeed", 16, 200, false)
CreateToggle("Enable Jump Boost", "JumpToggle")
CreateSlider("Jump Power", "JumpPower", 50, 350, false)
CreateToggle("Enable Flight Mode", "FlyToggle")
CreateSlider("Flight Speed", "FlySpeed", 10, 300, false)
CreateToggle("Auto Farm (Behind)", "AutoFarmPlayer")
CreateSlider("Farm Delay", "AutoFarmDelay", 0.01, 5, true)
CreateToggle("Bow Down", "BowDown")
CreateSlider("Bow Angle", "BowAngle", 0, 90, false)
CreateSection("VISUALS & ESP")
CreateToggle("Master ESP Toggle", "EspMaster")
CreateToggle("Show ESP Box", "EspBox")
CreateToggle("Show ESP Tracer", "EspTracer")
CreateToggle("Show Name Tags", "EspName")
CreateToggle("Show Health Bar", "EspHealth")
CreateSlider("ESP Transparency", "EspTransparency", 0, 100, false)
CreateSlider("Max Distance", "MaxDistance", 100, 5000, false)
CreateToggle("FullBright", "FullBright", function(state)
    if state then Lighting.Ambient = Color3.fromRGB(255, 255, 255) Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else Lighting.Ambient = Config.StoredAmbient Lighting.OutdoorAmbient = Config.StoredOutdoorAmbient end
end)

CreateSection("MISC & MOBILE")
CreateToggle("Force Third Person", "ThirdPerson")
CreateSlider("Third Person Dist", "ThirdPersonDist", 5, 100, false)
CreateToggle("Show FOV Circle", "FovCircle")
CreateSlider("FOV Radius", "FovRadius", 30, 500, false)
CreateToggle("Show Crosshair Dot", "CrosshairDot")
CreateToggle("Anti-AFK", "AntiAFK")
CreateToggle("Lock Mobile Buttons", "LockMobileButtons")
CreateToggle("Show Mobile Aimbot", "ShowMobileAim")
CreateToggle("Show Mobile Trigger", "ShowMobileTrig")
CreateToggle("Show Mobile Speed", "ShowMobileSpeed")
CreateToggle("Show Mobile Farm", "ShowMobileFarm")
CreateToggle("Show Mobile Aura", "ShowMobileAura")
CreateToggle("Show Mobile 3rd P", "ShowMobileTP")
CreateToggle("Show Mobile Fly", "ShowMobileFly")

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.MenuKeybind then Config.MenuVisible = not Config.MenuVisible MainFrame.Visible = Config.MenuVisible
    elseif input.KeyCode == Config.AimbotKeybind and Config.AimbotKeybind ~= Enum.KeyCode.Unknown then Config.Aimbot = not Config.Aimbot for _, r in pairs(UI_Refresh_Functions) do pcall(r) end
    elseif input.KeyCode == Config.AuraKeybind and Config.AuraKeybind ~= Enum.KeyCode.Unknown then Config.Aura = not Config.Aura for _, r in pairs(UI_Refresh_Functions) do pcall(r) end
    elseif input.KeyCode == Config.TriggerbotKeybind and Config.TriggerbotKeybind ~= Enum.KeyCode.Unknown then Config.Triggerbot = not Config.Triggerbot for _, r in pairs(UI_Refresh_Functions) do pcall(r) end
    elseif input.KeyCode == Config.SpinbotKeybind and Config.SpinbotKeybind ~= Enum.KeyCode.Unknown then Config.Spinbot = not Config.Spinbot for _, r in pairs(UI_Refresh_Functions) do pcall(r) end
    elseif input.KeyCode == Config.EspMasterKeybind and Config.EspMasterKeybind ~= Enum.KeyCode.Unknown then Config.EspMaster = not Config.EspMaster for _, r in pairs(UI_Refresh_Functions) do pcall(r) end
    elseif input.KeyCode == Config.SpeedKeybind and Config.SpeedKeybind ~= Enum.KeyCode.Unknown then Config.SpeedToggle = not Config.SpeedToggle for _, r in pairs(UI_Refresh_Functions) do pcall(r) end
    elseif input.KeyCode == Config.JumpKeybind and Config.JumpKeybind ~= Enum.KeyCode.Unknown then Config.JumpToggle = not Config.JumpToggle for _, r in pairs(UI_Refresh_Functions) do pcall(r) end
    elseif input.KeyCode == Config.FlyKeybind and Config.FlyKeybind ~= Enum.KeyCode.Unknown then Config.FlyToggle = not Config.FlyToggle for _, r in pairs(UI_Refresh_Functions) do pcall(r) end
    end
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
    local Root = Character:WaitForChild("HumanoidRootPart", 5)
    local Head = Character:WaitForChild("Head", 5)
    if not Root or not Head then return end
    
    CleanCharacterVisuals(Character)
    local Box = Instance.new("BoxHandleAdornment")
    Box.Name = "WangBoxFill" Box.Parent = Root Box.Adornee = Root Box.AlwaysOnTop = true Box.ZIndex = 10 Box.Size = Vector3.new(4, 6, 4) Box.Visible = false

    local Gui = Instance.new("BillboardGui")
    Gui.Name = "WangInfoTag" Gui.Adornee = Head Gui.Size = UDim2.new(0, 200, 0, 100) Gui.StudsOffset = Vector3.new(0, 4, 0) Gui.AlwaysOnTop = true

    local Label = Instance.new("TextLabel", Gui)
    Label.Size = UDim2.new(1, 0, 0, 40) Label.BackgroundTransparency = 1 Label.Font = Enum.Font.Code Label.TextSize = 13 Label.TextColor3 = Config.EspColor
    
    local HealthBG = Instance.new("Frame", Gui)
    HealthBG.Name = "HealthBG" HealthBG.BackgroundColor3 = Color3.fromRGB(40, 0, 0) HealthBG.BorderSizePixel = 1 HealthBG.Position = UDim2.new(0.25, 0, 0, 45) HealthBG.Size = UDim2.new(0.5, 0, 0, 5) HealthBG.Visible = false
    
    local HealthBar = Instance.new("Frame", HealthBG)
    HealthBar.Name = "HealthBar" HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100) HealthBar.BorderSizePixel = 0 HealthBar.Size = UDim2.new(1, 0, 1, 0)

    Gui.Parent = Head
    Character_Cache[Character] = { Box = Box, Gui = Gui, Label = Label, HealthBG = HealthBG, HealthBar = HealthBar, Player = Player }
end

local function MonitorPlayer(Player)
    if Player == LocalPlayer then return end
    Player.CharacterAdded:Connect(function(Char) task.spawn(RenderVisuals, Player, Char) end)
    if Player.Character then task.spawn(RenderVisuals, Player, Player.Character) end
end
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
            
            if Config.FlyToggle then
                local bg = MyRoot:FindFirstChild("WangFlyBG") or Instance.new("BodyGyro")
                bg.Name = "WangFlyBG" bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.Parent = MyRoot
                local bv = MyRoot:FindFirstChild("WangFlyBV") or Instance.new("BodyVelocity")
                bv.Name = "WangFlyBV" bv.maxForce = Vector3.new(9e9, 9e9, 9e9) bv.Parent = MyRoot
                
                local moveDir = MyHum.MoveDirection
                local flyVel = moveDir * Config.FlySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyVel = flyVel + Vector3.new(0, Config.FlySpeed, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then flyVel = flyVel - Vector3.new(0, Config.FlySpeed, 0) end
                bv.velocity = flyVel
                
                if moveDir.Magnitude > 0 then bg.cframe = CFrame.new(MyRoot.Position, MyRoot.Position + moveDir)
                else bg.cframe = Camera.CFrame end
            else
                if MyRoot:FindFirstChild("WangFlyBG") then MyRoot.WangFlyBG:Destroy() end
                if MyRoot:FindFirstChild("WangFlyBV") then MyRoot.WangFlyBV:Destroy() end
            end
        end
        if Config.Spinbot then
            CurrentSpinAngle = (CurrentSpinAngle + Config.SpinSpeed) % 360
            MyRoot.CFrame = CFrame.new(MyRoot.CFrame.Position) * CFrame.Angles(0, math.rad(CurrentSpinAngle), 0)
        end
        
        local headInstance = MyChar:FindFirstChild("Head")
        local torsoInstance = MyChar:FindFirstChild("UpperTorso") or MyChar:FindFirstChild("Torso")
        local neckJoint = (headInstance and headInstance:FindFirstChild("Neck")) or (torsoInstance and torsoInstance:FindFirstChild("Neck"))
        if neckJoint and neckJoint:IsA("Motor6D") then
            if not NeckCache[neckJoint] then NeckCache[neckJoint] = neckJoint.C0 end
            if Config.BowDown then neckJoint.C0 = NeckCache[neckJoint] * CFrame.Angles(math.rad(-Config.BowAngle), 0, 0)
            else neckJoint.C0 = NeckCache[neckJoint] end
        end
        
        if Config.Aura then
            if AuraVisual.Parent ~= MyRoot then AuraVisual.Parent = MyRoot AuraVisual.Adornee = MyRoot end
            AuraVisual.Height = 0.08 AuraVisual.Radius = Config.AuraRadius AuraVisual.Color3 = Config.AuraColor
            AuraVisual.Transparency = Config.AuraTransparency / 100 AuraVisual.CFrame = CFrame.new(0, -3.1, 0) * CFrame.Angles(math.rad(90), 0, 0) AuraVisual.Visible = true
        else AuraVisual.Visible = false end
    else 
        AuraVisual.Visible = false
        if MyRoot then
            if MyRoot:FindFirstChild("WangFlyBG") then MyRoot.WangFlyBG:Destroy() end
            if MyRoot:FindFirstChild("WangFlyBV") then MyRoot.WangFlyBV:Destroy() end
        end
    end

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
end)
RunService.RenderStepped:Connect(function()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local ScreenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    local MyChar = LocalPlayer.Character
    
    for Char, Data in pairs(Character_Cache) do
        if Char and Char.Parent and IsAlive(Char) then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            if Config.EspMaster and Root and MyChar and MyChar:FindFirstChild("HumanoidRootPart") and Hum then
                local PColor = GetPlayerColor(Data.Player)
                local Dist = math.floor((Root.Position - MyChar.HumanoidRootPart.Position).Magnitude)

                if Config.EspBox and Dist <= Config.MaxDistance then Data.Box.Visible = true Data.Box.Color3 = PColor Data.Box.Transparency = Config.EspTransparency / 100 else Data.Box.Visible = false end
                if Config.EspName and Dist <= Config.MaxDistance then Data.Gui.Enabled = true Data.Label.Visible = true Data.Label.TextColor3 = PColor Data.Label.Text = string.format("%s (%dm)\\n[%s] [%s]", Data.Player.Name, Dist, Data.Player.Team and Data.Player.Team.Name or "No Team", GetEquippedTool(Char)) else Data.Label.Visible = false end
                if Config.EspHealth and Dist <= Config.MaxDistance then Data.Gui.Enabled = true Data.HealthBG.Visible = true local HealthPercent = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1) Data.HealthBar.Size = UDim2.new(HealthPercent, 0, 1, 0) Data.HealthBar.BackgroundColor3 = Color3.fromHSV(HealthPercent * 0.35, 1, 1) else Data.HealthBG.Visible = false end

                local Tracer = Tracer_Cache[Data.Player]
                if Tracer and Config.EspTracer and Dist <= Config.MaxDistance then
                    local Leg, OnScreen = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
                    if OnScreen then Tracer.From = Config.TracerMode == "Center" and ScreenCenter or ScreenBottom Tracer.To = Vector2.new(Leg.X, Leg.Y) Tracer.Color = PColor Tracer.Visible = true else Tracer.Visible = false end
                elseif Tracer then Tracer.Visible = false end
            else Data.Box.Visible = false Data.Label.Visible = false Data.HealthBG.Visible = false if Tracer_Cache[Data.Player] then Tracer_Cache[Data.Player].Visible = false end end
        else CleanCharacterVisuals(Char) Character_Cache[Char] = nil end
    end
end)

Players.PlayerAdded:Connect(function(Player) CreateTracerObject(Player) MonitorPlayer(Player) end)
Players.PlayerRemoving:Connect(function(Player) ClearTracerObject(Player) end)

for _, P in pairs(Players:GetPlayers()) do CreateTracerObject(P) MonitorPlayer(P) end

for _, refresh in pairs(UI_Refresh_Functions) do pcall(refresh) end

task.spawn(function()
    while task.wait(3) do
        SaveConfigToFile()
    end
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "WANGCAOS CLIENT V7.8",
        Text = "Auto-Save System & COMPACT GUI V7.8 loaded successfully!",
        Duration = 7
    })
end)
-- ==============================================================================
-- END OF SCRIPT - POWERED FOR WANG (2026)
-- ==============================================================================
