--============================================================
-- EBALSUKU ULTIMATE (FIXED BINDS v2)
--============================================================
local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local LG = game:GetService("Lighting")
local SS = game:GetService("SoundService")
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local HS = game:GetService("HttpService")
local LP = P.LocalPlayer
local PG = LP:WaitForChild("PlayerGui", 10) or game:GetService("CoreGui")

local State = {}
local Callbacks = {} -- Хранилище коллбеков
local GlobalColor = Color3.fromRGB(255, 50, 50)
local SAVE_FILE = "ebalsuku_state.json"

-- СИСТЕМА СОХРАНЕНИЯ
local function SaveState()
    if not writefile then return end
    pcall(function() writefile(SAVE_FILE, HS:JSONEncode(State)) end)
end
local function LoadState()
    if not readfile or not isfile then return end
    pcall(function()
        if isfile(SAVE_FILE) then
            local data = HS:JSONDecode(readfile(SAVE_FILE))
            for k, v in pairs(data) do State[k] = v end
        end
    end)
end
LoadState()

local function smooth(o, t, p, s, d)
    s = s or Enum.EasingStyle.Quint; d = d or Enum.EasingDirection.Out
    TS:Create(o, TweenInfo.new(t, s, d), p):Play()
end

local UIElements = {}
local function ToggleState(name, callback)
    State[name] = not State[name]
    SaveState()
    if UIElements[name] then
        local data = UIElements[name]
        smooth(data.Bg, 0.2, {BackgroundColor3 = State[name] and GlobalColor or Color3.fromRGB(35, 35, 40)})
        smooth(data.Knob, 0.2, {Position = State[name] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, Enum.EasingStyle.Back)
    end
    if callback then pcall(callback, State[name]) end
end

local VisualObjects = {HL = {}, Box = {}, Tracer = {}, Sphere = {}, Name = {}}
local function UpdateVisualColors()
    for _, obj in pairs(VisualObjects.HL) do obj.FillColor = GlobalColor end
    for _, obj in pairs(VisualObjects.Box) do obj.Color3 = GlobalColor end
    for _, obj in pairs(VisualObjects.Tracer) do obj.Color3 = GlobalColor end
    for _, obj in pairs(VisualObjects.Sphere) do obj.Color = GlobalColor end
    for _, obj in pairs(VisualObjects.Name) do obj.TextLabel.TextColor3 = GlobalColor end
    for _, obj in pairs(UIElements) do
        if obj.Bg.BackgroundColor3 ~= Color3.fromRGB(35, 35, 40) then obj.Bg.BackgroundColor3 = GlobalColor end
    end
end

-- GUI ОСНОВА
local SG = Instance.new("ScreenGui")
SG.Name = "EbalsukuMega"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.DisplayOrder = 9999
SG.Parent = PG

local Main
local OpenBtn = Instance.new("TextButton", SG)
OpenBtn.Size = UDim2.new(0, 44, 0, 44)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
OpenBtn.Text = "E"
OpenBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 16
OpenBtn.AutoButtonColor = false
OpenBtn.ZIndex = 100
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local oStroke = Instance.new("UIStroke", OpenBtn)
oStroke.Color = Color3.fromRGB(50, 50, 55)
oStroke.Thickness = 1.5
oStroke.ZIndex = 101

Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 520, 0, 360)
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.BackgroundTransparency = 0.05
Main.Visible = false
Main.Active = true
Main.ZIndex = 50
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", Main)
mStroke.Color = Color3.fromRGB(35, 35, 40)
mStroke.Thickness = 1.5

local Shadow = Instance.new("ImageLabel", Main)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.ZIndex = 49

local function CloseMenu()
    smooth(Main, 0.2, {Size = UDim2.new(0, 0, 0, 0)})
    task.wait(0.2)
    Main.Visible = false 
    OpenBtn.Visible = true 
end
local function OpenMenu()
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    smooth(Main, 0.3, {Size = UDim2.new(0, 520, 0, 360)}, Enum.EasingStyle.Back)
    OpenBtn.Visible = false
end

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 105
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(CloseMenu)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then CloseMenu() else OpenMenu() end
    end
end)

local nDrag, nStart, nPos, nMoved = false, nil, nil, false
OpenBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        nDrag = true; nMoved = false; nStart = i.Position; nPos = OpenBtn.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if nDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - nStart
        if d.Magnitude > 15 then nMoved = true end
        if nMoved then OpenBtn.Position = UDim2.new(nPos.X.Scale, nPos.X.Offset + d.X, nPos.Y.Scale, nPos.Y.Offset + d.Y) end
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if not nDrag then return end
        local w = nMoved; nDrag = false; nMoved = false
        if not w then if Main.Visible then CloseMenu() else OpenMenu() end end
    end
end)

local DragBar = Instance.new("Frame", Main)
DragBar.Size = UDim2.new(1, -60, 0, 40)
DragBar.Position = UDim2.new(0, 10, 0, 5)
DragBar.BackgroundTransparency = 1
DragBar.Active = true
DragBar.ZIndex = 110
local mDrag, mStart, mPos = false, nil, nil
DragBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mDrag = true; mStart = i.Position; mPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if mDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - mStart
        Main.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + d.X, mPos.Y.Scale, mPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mDrag = false end
end)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
Sidebar.BackgroundTransparency = 0.2
Sidebar.ZIndex = 52
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "MEGA PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.ZIndex = 53

local TabList = Instance.new("Frame", Sidebar)
TabList.Size = UDim2.new(1, -10, 1, -60)
TabList.Position = UDim2.new(0, 5, 0, 50)
TabList.BackgroundTransparency = 1
TabList.ZIndex = 53
local TabLayout = Instance.new("UIListLayout", TabList)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -140, 1, -20)
Content.Position = UDim2.new(0, 140, 0, 10)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 55)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ZIndex = 52
local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)
local ContentPad = Instance.new("UIPadding", Content)
ContentPad.PaddingTop = UDim.new(0, 10)
ContentPad.PaddingLeft = UDim.new(0, 10)
ContentPad.PaddingRight = UDim.new(0, 10)

-- UI ХЕЛПЕРЫ
local function MakeTab(name)
    local Btn = Instance.new("TextButton", TabList)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Btn.BackgroundTransparency = 1
    Btn.Text = "  " .. name
    Btn.TextColor3 = Color3.fromRGB(140, 140, 150)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.AutoButtonColor = false
    Btn.ZIndex = 54
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseEnter:Connect(function() if Btn.BackgroundTransparency == 1 then smooth(Btn, 0.2, {BackgroundTransparency = 0.6}) end end)
    Btn.MouseLeave:Connect(function() if Btn.TextColor3 ~= Color3.fromRGB(255, 255, 255) then smooth(Btn, 0.2, {BackgroundTransparency = 1}) end end)
    return Btn
end

local function SwitchTab(activeBtn, activeFrame)
    for _, btn in ipairs(TabList:GetChildren()) do
        if btn:IsA("TextButton") then smooth(btn, 0.2, {TextColor3 = Color3.fromRGB(140, 140, 150), BackgroundTransparency = 1}) end
    end
    smooth(activeBtn, 0.2, {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.3, BackgroundColor3 = GlobalColor})
    for _, frame in ipairs(Content:GetChildren()) do if frame:IsA("Frame") then frame.Visible = false end end
    activeFrame.Visible = true
end

local function CreatePage()
    local Page = Instance.new("Frame", Content)
    Page.Size = UDim2.new(1, -10, 0, 0)
    Page.AutomaticSize = Enum.AutomaticSize.Y
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ZIndex = 53
    local Layout = Instance.new("UIListLayout", Page)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 6)
    return Page
end

local function AddSection(parent, text)
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(100, 100, 110)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 9
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 54
end

local function AddToggle(parent, name, default, callback)
    State[name] = State[name] ~= nil and State[name] or default
    Callbacks[name] = callback -- Сохраняем коллбек
    local currentState = State[name]

    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 26)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 54
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 55
    
    local SwitchBg = Instance.new("Frame", Frame)
    SwitchBg.Size = UDim2.new(0, 30, 0, 16)
    SwitchBg.Position = UDim2.new(1, -30, 0.5, -8)
    SwitchBg.BackgroundColor3 = currentState and GlobalColor or Color3.fromRGB(35, 35, 40)
    SwitchBg.ZIndex = 55
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame", SwitchBg)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = currentState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.ZIndex = 56
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
    local Click = Instance.new("TextButton", Frame)
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.BackgroundTransparency = 1
    Click.Text = ""
    Click.ZIndex = 57
    
    UIElements[name] = {Bg = SwitchBg, Knob = Knob}
    
    Click.MouseButton1Click:Connect(function()
        ToggleState(name, callback)
    end)

    if currentState and callback then
        task.spawn(function()
            task.wait(1.5)
            pcall(callback, true)
        end)
    end
end

local function AddSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 54
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 55
    local BarBg = Instance.new("Frame", Frame)
    BarBg.Size = UDim2.new(1, 0, 0, 4)
    BarBg.Position = UDim2.new(0, 0, 0, 20)
    BarBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    BarBg.ZIndex = 55
    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", BarBg)
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = GlobalColor
    Fill.ZIndex = 56
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    local Knob = Instance.new("Frame", BarBg)
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.Position = UDim2.new((default - min)/(max - min), -5, 0.5, -5)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.ZIndex = 57
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local Dragging = false
    local function Update(x)
        local percent = math.clamp((x - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + percent * (max - min))
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Knob.Position = UDim2.new(percent, -5, 0.5, -5)
        Label.Text = text .. ": " .. val
        pcall(callback, val)
    end
    BarBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = true; Update(input.Position.X) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input.Position.X) end
    end)
end

-- ВКЛАДКИ
local VTab = MakeTab("Visuals"); local VPage = CreatePage(); VTab.MouseButton1Click:Connect(function() SwitchTab(VTab, VPage) end)
local PTab = MakeTab("Particles"); local PPage = CreatePage(); PTab.MouseButton1Click:Connect(function() SwitchTab(PTab, PPage) end)
local MTab = MakeTab("Movement"); local MPage = CreatePage(); MTab.MouseButton1Click:Connect(function() SwitchTab(MTab, MPage) end)
local CTab = MakeTab("Combat"); local CPage = CreatePage(); CTab.MouseButton1Click:Connect(function() SwitchTab(CTab, CPage) end)
local RTab = MakeTab("Rage"); local RPage = CreatePage(); RTab.MouseButton1Click:Connect(function() SwitchTab(RTab, RPage) end)
local GTab = MakeTab("Graphics"); local GPage = CreatePage(); GTab.MouseButton1Click:Connect(function() SwitchTab(GTab, GPage) end)
local STab = MakeTab("Scripts"); local SPage = CreatePage(); STab.MouseButton1Click:Connect(function() SwitchTab(STab, SPage) end)
local BTab = MakeTab("Binds"); local BPage = CreatePage(); BTab.MouseButton1Click:Connect(function() SwitchTab(BTab, BPage) end)
local HTab = MakeTab("Hit Sounds"); local HPage = CreatePage(); HTab.MouseButton1Click:Connect(function() SwitchTab(HTab, HPage) end)
SwitchTab(VTab, VPage)

--============================================================
-- HIT SOUNDS
--============================================================
AddSection(HPage, "Звуки Убийств (Hit Sounds)")
local hitSoundList = {
    {name = "CS:GO Hit", id = "rbxassetid://80258601122813"},
    {name = "Minecraft Hit (HD)", id = "rbxassetid://7273736372"},
    {name = "Minecraft Hit", id = "rbxassetid://5984353288"},
    {name = "Minecraft Crit", id = "rbxassetid://8458185621"},
    {name = "Minecraft Crit 2", id = "rbxassetid://6361963422"},
    {name = "Minecraft Noooo", id = "rbxassetid://2618158728"},
    {name = "Bass Hit", id = "rbxassetid://12221944"},
    {name = "Рандом (Все)"}
}

local currentHitSound = 1
local killSoundOn = State["Kill Sounds"] or false

AddToggle(HPage, "Включить звуки убийств", false, function(s) killSoundOn = s end)

local soundLabel = Instance.new("TextLabel", HPage)
soundLabel.Size = UDim2.new(1, 0, 0, 26)
soundLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
soundLabel.Text = "Звук: " .. hitSoundList[currentHitSound].name
soundLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
soundLabel.Font = Enum.Font.Gotham
soundLabel.TextSize = 11
soundLabel.ZIndex = 55
Instance.new("UICorner", soundLabel).CornerRadius = UDim.new(0, 6)

local nextSoundBtn = Instance.new("TextButton", HPage)
nextSoundBtn.Size = UDim2.new(1, 0, 0, 26)
nextSoundBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
nextSoundBtn.Text = "Следующий звук ▶"
nextSoundBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextSoundBtn.Font = Enum.Font.GothamBold
nextSoundBtn.TextSize = 11
nextSoundBtn.ZIndex = 55
Instance.new("UICorner", nextSoundBtn).CornerRadius = UDim.new(0, 6)
nextSoundBtn.MouseButton1Click:Connect(function()
    currentHitSound = currentHitSound + 1
    if currentHitSound > #hitSoundList then currentHitSound = 1 end
    soundLabel.Text = "Звук: " .. hitSoundList[currentHitSound].name
end)

local playTestBtn = Instance.new("TextButton", HPage)
playTestBtn.Size = UDim2.new(1, 0, 0, 26)
playTestBtn.BackgroundColor3 = GlobalColor
playTestBtn.Text = "Прослушать"
playTestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playTestBtn.Font = Enum.Font.GothamBold
playTestBtn.TextSize = 11
playTestBtn.ZIndex = 55
Instance.new("UICorner", playTestBtn).CornerRadius = UDim.new(0, 6)
playTestBtn.MouseButton1Click:Connect(function()
    local soundData = hitSoundList[currentHitSound]
    local s = Instance.new("Sound", SS)
    if soundData.name == "Рандом (Все)" then
        local randomIdx = math.random(1, #hitSoundList - 1)
        s.SoundId = hitSoundList[randomIdx].id
    else
        s.SoundId = soundData.id
    end
    s.Volume = 1
    s:Play()
    Debris:AddItem(s, 2)
end)

local killVolume = 1
AddSlider(HPage, "Громкость", 0, 100, 100, function(v) killVolume = v / 100 end)

local function PlayKillSound()
    if not killSoundOn then return end
    local soundData = hitSoundList[currentHitSound]
    local s = Instance.new("Sound", SS)
    s.Volume = killVolume
    if soundData.name == "Рандом (Все)" then
        local randomIdx = math.random(1, #hitSoundList - 1)
        s.SoundId = hitSoundList[randomIdx].id
    else
        s.SoundId = soundData.id
    end
    s:Play()
    Debris:AddItem(s, 2)
end

local function setupDeathListener(character)
    local humanoid = character and character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.Died:Connect(function()
            if character.Name ~= LP.Name then
                PlayKillSound()
            end
        end)
    end
end

for _, p in ipairs(P:GetPlayers()) do
    if p.Character then setupDeathListener(p.Character) end
    p.CharacterAdded:Connect(setupDeathListener)
end
P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(setupDeathListener)
    if p.Character then setupDeathListener(p.Character) end
end)

--============================================================
-- САТУРН
--============================================================
AddSection(RPage, "Saturn (Orbit Around Player)")
local SaturnRadius, SaturnSpeed, SaturnHeight = 10, 2, 3
local SaturnAngle = 0
local saturnAlignPos, saturnAlignOri

AddSlider(RPage, "Saturn Radius", 3, 30, 10, function(v) SaturnRadius = v end)
AddSlider(RPage, "Saturn Speed", 1, 10, 2, function(v) SaturnSpeed = v end)
AddSlider(RPage, "Saturn Height", 0, 20, 3, function(v) SaturnHeight = v end)

AddToggle(RPage, "Включить Сатурн", false, function(s)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    if s then
        hum.PlatformStand = true
        saturnAlignPos = Instance.new("AlignPosition", hrp)
        saturnAlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        saturnAlignPos.Attachment0 = Instance.new("Attachment", hrp)
        saturnAlignPos.MaxForce = 100000
        saturnAlignPos.Responsiveness = 15
        
        saturnAlignOri = Instance.new("AlignOrientation", hrp)
        saturnAlignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
        saturnAlignOri.Attachment0 = saturnAlignPos.Attachment0
        saturnAlignOri.MaxTorque = 100000
        saturnAlignOri.Responsiveness = 15
    else
        hum.PlatformStand = false
        if saturnAlignPos then saturnAlignPos:Destroy() end
        if saturnAlignOri then saturnAlignOri:Destroy() end
        if hrp then hrp.Velocity = Vector3.zero end
    end
end)

RS.Heartbeat:Connect(function(dt)
    if State["Включить Сатурн"] and saturnAlignPos and saturnAlignOri then
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local closest, dist = nil, math.huge
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local thrp = p.Character.HumanoidRootPart
                local d = (thrp.Position - hrp.Position).Magnitude
                if d < dist then dist = d; closest = thrp end
            end
        end
        
        if closest then
            SaturnAngle = SaturnAngle + dt * SaturnSpeed
            local offset = Vector3.new(math.cos(SaturnAngle) * SaturnRadius, SaturnHeight, math.sin(SaturnAngle) * SaturnRadius)
            saturnAlignPos.Position = closest.Position + offset
            saturnAlignOri.CFrame = CFrame.lookAt(hrp.Position, closest.Position)
        end
    end
end)

--============================================================
-- FOV
--============================================================
AddSection(VPage, "Настройки Камеры")
local FOVValue = State["FOV"] or 70
AddSlider(VPage, "FOV", 70, 120, 70, function(v)
    FOVValue = v
    State["FOV"] = v
    SaveState()
    if WS.CurrentCamera then
        WS.CurrentCamera.FieldOfView = v
    end
end)
if State["FOV"] then
    if WS.CurrentCamera then
        WS.CurrentCamera.FieldOfView = State["FOV"]
    end
end

--============================================================
-- ЦВЕТА
--============================================================
AddSection(VPage, "Смена цвета визуалов")
local Colors = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Blue = Color3.fromRGB(50, 50, 255),
    Purple = Color3.fromRGB(180, 50, 255),
    Cyan = Color3.fromRGB(0, 255, 255),
    White = Color3.fromRGB(255, 255, 255)
}
local function AddColorButton(parent, name, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.3, -4, 0, 24)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.ZIndex = 55
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        GlobalColor = color
        UpdateVisualColors()
    end)
    return btn
end
local ColorFrame = Instance.new("Frame", VPage)
ColorFrame.Size = UDim2.new(1, 0, 0, 24)
ColorFrame.BackgroundTransparency = 1
ColorFrame.ZIndex = 54
local ColorLayout = Instance.new("UIListLayout", ColorFrame)
ColorLayout.FillDirection = Enum.FillDirection.Horizontal
ColorLayout.Padding = UDim.new(0, 4)
AddColorButton(ColorFrame, "Red", Colors.Red)
AddColorButton(ColorFrame, "Green", Colors.Green)
AddColorButton(ColorFrame, "Blue", Colors.Blue)

--============================================================
-- VISUALS (ESP)
--============================================================
AddSection(VPage, "ESP (Shitaro Style)")
AddToggle(VPage, "Highlight ESP", false, function(s) 
    if s then 
    else 
        for _, p in pairs(VisualObjects.HL) do p:Destroy() end; VisualObjects.HL = {} 
    end 
end)
AddToggle(VPage, "Box ESP", false, function(s) if not s then for _, p in pairs(VisualObjects.Box) do p:Destroy() end; VisualObjects.Box = {} end end)
AddToggle(VPage, "Tracers (3D)", false, function(s) if not s then for _, p in pairs(VisualObjects.Tracer) do p:Destroy() end; VisualObjects.Tracer = {} end end)
AddToggle(VPage, "Neon Spheres", false, function(s) if not s then for _, p in pairs(VisualObjects.Sphere) do p:Destroy() end; VisualObjects.Sphere = {} end end)

--============================================================
-- PARTICLES & TRAILS
--============================================================
AddSection(PPage, "Мега Частицы (Particles)")
local ParticleObjects = {}
local function CreateParticles(parent, color, isBig)
    local att = Instance.new("Attachment", parent)
    local emitter = Instance.new("ParticleEmitter", att)
    emitter.Texture = "rbxassetid://243660364"
    emitter.Color = ColorSequence.new(color, Color3.fromRGB(255, 255, 255))
    emitter.LightEmission = 1
    emitter.LightInfluence = 0
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, isBig and 3 or 1.5), NumberSequenceKeypoint.new(0.5, isBig and 5 or 2), NumberSequenceKeypoint.new(1, 0)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
    emitter.Lifetime = NumberRange.new(1, 2.5)
    emitter.Rate = isBig and 50 or 20
    emitter.Speed = NumberRange.new(2, 8)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-90, 90)
    return att, emitter
end

AddToggle(PPage, "Ореол вокруг меня (Мега)", false, function(s)
    if s then
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local att, emitter = CreateParticles(char.HumanoidRootPart, GlobalColor, true)
            emitter.Speed = NumberRange.new(5, 15)
            ParticleObjects["Aura"] = {Att = att, Em = emitter}
        end
    else
        if ParticleObjects["Aura"] then ParticleObjects["Aura"].Att:Destroy(); ParticleObjects["Aura"] = nil end
    end
end)

AddToggle(PPage, "Мега Частицы за всеми игроками", false, function(s)
    if s then
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local att, emitter = CreateParticles(p.Character.HumanoidRootPart, GlobalColor, true)
                ParticleObjects["All_" .. p.Name] = {Att = att, Em = emitter}
            end
        end
        P.PlayerAdded:Connect(function(newP)
            if State["Мега Частицы за всеми игроками"] and newP.Character and newP.Character:FindFirstChild("HumanoidRootPart") then
                local att, emitter = CreateParticles(newP.Character.HumanoidRootPart, GlobalColor, true)
                ParticleObjects["All_" .. newP.Name] = {Att = att, Em = emitter}
            end
        end)
    else
        for k, v in pairs(ParticleObjects) do
            if string.find(k, "All_") then v.Att:Destroy(); ParticleObjects[k] = nil end
        end
    end
end)

AddSection(PPage, "Фиолетовые шарики")
local purpleRainOn = false
AddToggle(PPage, "Шарики (Дождь от меня и других)", false, function(s) purpleRainOn = s end)
task.spawn(function()
    while task.wait(0.1) do
        if purpleRainOn then
            for _, p in ipairs(P:GetPlayers()) do
                local char = p.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local ball = Instance.new("Part")
                    ball.Shape = Enum.PartType.Ball
                    ball.Size = Vector3.new(0.6, 0.6, 0.6)
                    ball.Material = Enum.Material.Neon
                    ball.Color = Color3.fromRGB(100, 20, 150) 
                    ball.Transparency = 0.1
                    ball.CanCollide = false
                    ball.Anchored = false
                    ball.Position = hrp.Position + Vector3.new(math.random(-5,5), math.random(3,6), math.random(-5,5))
                    local light = Instance.new("PointLight", ball)
                    light.Color = Color3.fromRGB(150, 50, 255)
                    light.Range = 5
                    light.Brightness = 1
                    ball.Velocity = Vector3.new(0, -5, 0)
                    ball.Parent = WS
                    task.delay(1.5, function()
                        if ball and ball.Parent then
                            TS:Create(ball, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0,0,0)}):Play()
                            Debris:AddItem(ball, 0.5)
                        end
                    end)
                end
            end
        end
    end
end)

AddSection(PPage, "Визуалы прыжка (Волны)")
local jumpWaveOn = false
AddToggle(PPage, "Фиолетовые волны при прыжке", false, function(s) jumpWaveOn = s end)
local lastFloor = Enum.Material.Plastic
RS.Heartbeat:Connect(function()
    if not jumpWaveOn then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    local currentFloor = hum.FloorMaterial
    if lastFloor ~= Enum.Material.Air and currentFloor == Enum.Material.Air then
        local wave = Instance.new("Part")
        wave.Shape = Enum.PartType.Cylinder
        wave.Size = Vector3.new(0.1, 2, 2)
        wave.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
        wave.Color = Color3.fromRGB(180, 50, 255)
        wave.Material = Enum.Material.Neon
        wave.Transparency = 0.3
        wave.Anchored = true
        wave.CanCollide = false
        wave.Parent = WS
        
        TS:Create(wave, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.1, 15, 15),
            Transparency = 1
        }):Play()
        Debris:AddItem(wave, 0.6)
    end
    lastFloor = currentFloor
end)

AddToggle(PPage, "Трейл за мной (След)", false, function(s)
    if s then
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local a0 = Instance.new("Attachment", hrp); a0.Position = Vector3.new(1, 0, 0)
            local a1 = Instance.new("Attachment", hrp); a1.Position = Vector3.new(-1, 0, 0)
            local trail = Instance.new("Trail", hrp)
            trail.Attachment0 = a0; trail.Attachment1 = a1
            trail.Lifetime = 1
            trail.Color = ColorSequence.new(GlobalColor, Color3.fromRGB(255, 255, 255))
            trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
            ParticleObjects["Trail"] = trail
        end
    else
        if ParticleObjects["Trail"] then ParticleObjects["Trail"]:Destroy(); ParticleObjects["Trail"] = nil end
    end
end)

--============================================================
-- MOVEMENT
--============================================================
local FlyVel, FlyGyro
local FlySpeed = 50
local SpeedVal = 16
local spinSpeed = 10
AddSection(MPage, "Speed & Fly")
AddSlider(MPage, "Скорость", 16, 500, 16, function(v) SpeedVal = v; if State["Speed Hack"] and LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end end)
AddToggle(MPage, "Speed Hack", false, function(s) if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = s and SpeedVal or 16 end end)
AddSlider(MPage, "Fly Speed", 10, 300, 50, function(v) FlySpeed = v end)
AddToggle(MPage, "Fly", false, function(s)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if s then
        FlyVel = Instance.new("BodyVelocity", hrp); FlyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
        FlyGyro = Instance.new("BodyGyro", hrp); FlyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        LP.Character.Humanoid.PlatformStand = true
    else
        if FlyVel then FlyVel:Destroy() end; if FlyGyro then FlyGyro:Destroy() end
        LP.Character.Humanoid.PlatformStand = false
    end
end)
RS.RenderStepped:Connect(function()
    if State["Fly"] and FlyVel and FlyVel.Parent then
        local cam = WS.CurrentCamera; local mv = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
        FlyVel.Velocity = mv.Magnitude > 0 and mv.Unit * FlySpeed or Vector3.zero
        FlyGyro.CFrame = cam.CFrame
    end
end)

AddSection(MPage, "Fun Mods")
AddSlider(MPage, "Spin Speed", 1, 50, 10, function(v) spinSpeed = v end)
AddToggle(MPage, "Крутилка (Spin)", false, nil)
RS.Heartbeat:Connect(function()
    if State["Крутилка (Spin)"] then
        local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
    end
end)
AddToggle(MPage, "Прыжок с переворотом", false, nil)
UIS.JumpRequest:Connect(function()
    if State["Прыжок с переворотом"] then
        local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
        if hrp and hum then
            hum.Jump = true
            local flipAngle = 0
            local flipCon
            flipCon = RS.Heartbeat:Connect(function()
                if flipAngle >= math.pi * 2 or hum.FloorMaterial ~= Enum.Material.Air then flipCon:Disconnect(); return end
                flipAngle = flipAngle + 0.3
                hrp.CFrame = hrp.CFrame * CFrame.Angles(flipAngle, 0, 0)
            end)
        end
    end
end)
AddSection(MPage, "Backwards")
AddToggle(MPage, "Идти задом", false, nil)
RS.RenderStepped:Connect(function()
    if State["Идти задом"] then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local cam = WS.CurrentCamera; local look = cam.CFrame.LookVector; local flat = Vector3.new(look.X, 0, look.Z).Unit
            hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position - flat)
        end
    end
end)

--============================================================
-- COMBAT (АИМ НА БЛИЖАЙШЕГО)
--============================================================
local AimFOV = 300
local AimSmooth = 0.5
local AimTargetPart = "Head"
local AimCheckWall = false
local AimOn = false

AddSection(CPage, "Aimbot Settings")
AddSlider(CPage, "Aimbot FOV", 50, 1000, 300, function(v) AimFOV = v end)
AddSlider(CPage, "Aimbot Smoothness", 0.1, 1, 0.5, function(v) AimSmooth = v end)

local aimPartList = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
local aimPartIdx = 1
local aimPartBtn = Instance.new("TextButton", CPage)
aimPartBtn.Size = UDim2.new(1, 0, 0, 26)
aimPartBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
aimPartBtn.Text = "Цель: " .. AimTargetPart
aimPartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimPartBtn.Font = Enum.Font.GothamBold
aimPartBtn.TextSize = 11
aimPartBtn.ZIndex = 55
Instance.new("UICorner", aimPartBtn).CornerRadius = UDim.new(0, 6)
aimPartBtn.MouseButton1Click:Connect(function()
    aimPartIdx = aimPartIdx + 1
    if aimPartIdx > #aimPartList then aimPartIdx = 1 end
    AimTargetPart = aimPartList[aimPartIdx]
    aimPartBtn.Text = "Цель: " .. AimTargetPart
end)

AddToggle(CPage, "Проверка стен (Wall Check)", false, function(s) AimCheckWall = s end)
AddToggle(CPage, "Aimbot (Включить)", false, function(s) AimOn = s end)

local function GetClosestTarget(fov, checkWall)
    local cam = WS.CurrentCamera
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local best, shortestDist = nil, math.huge
    local center = cam.ViewportSize / 2
    
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(AimTargetPart) then
            local targetPart = p.Character[AimTargetPart]
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local sp, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if screenDist <= fov then
                        local canSee = true
                        if checkWall then
                            local ray = RaycastParams.new()
                            ray.FilterType = Enum.RaycastFilterType.Exclude
                            ray.FilterDescendantsInstances = {LP.Character, p.Character}
                            local hit = WS:Raycast(cam.CFrame.Position, targetPart.Position - cam.CFrame.Position, ray)
                            if hit then canSee = false end
                        end
                        
                        if canSee then
                            local worldDist = (targetPart.Position - myHRP.Position).Magnitude
                            if worldDist < shortestDist then
                                shortestDist = worldDist
                                best = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

RS.RenderStepped:Connect(function()
    if AimOn then
        local best = GetClosestTarget(AimFOV, AimCheckWall)
        if best then
            WS.CurrentCamera.CFrame = WS.CurrentCamera.CFrame:Lerp(CFrame.lookAt(WS.CurrentCamera.CFrame.Position, best.Position), AimSmooth)
        end
    end
end)

AddSection(CPage, "Combat Mods")
AddToggle(CPage, "God Mode (Infinite HP)", false, nil)
AddToggle(CPage, "Auto Heal", false, nil)
RS.Heartbeat:Connect(function()
    local h = LP.Character and LP.Character:FindFirstChild("Humanoid")
    if h then
        if State["God Mode (Infinite HP)"] then h.Health = h.MaxHealth end
        if State["Auto Heal"] and h.Health < h.MaxHealth then h.Health = h.Health + 1 end
    end
end)

local KARange = 15
AddSection(RPage, "Rage Features")
AddSlider(RPage, "Kill Aura Range", 5, 50, 15, function(v) KARange = v end)
AddToggle(RPage, "Kill Aura", false, nil)
RS.Heartbeat:Connect(function()
    if State["Kill Aura"] then
        local mh = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if mh then
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if (p.Character.HumanoidRootPart.Position - mh.Position).Magnitude <= KARange then
                        if p.Character:FindFirstChild("Humanoid") then p.Character.Humanoid.Health = 0 end
                    end
                end
            end
        end
    end
end)

--============================================================
-- GRAPHICS (RTX & ТУМАН)
--============================================================
local rtxObjects = {}
local function ApplyRTX(enable)
    if enable then
        rtxObjects = {}
        LG.FogColor = Color3.fromRGB(180, 50, 255) 
        LG.FogStart = 0; LG.FogEnd = 350
        LG.EnvironmentDiffuseScale = 1; LG.EnvironmentSpecularScale = 1 
        
        local bloom = Instance.new("BloomEffect", LG); bloom.Intensity = 1.5; bloom.Size = 24; bloom.Threshold = 0.8; table.insert(rtxObjects, bloom)
        local sr = Instance.new("SunRaysEffect", LG); sr.Intensity = 0.15; sr.Spread = 1; table.insert(rtxObjects, sr)
        local cc = Instance.new("ColorCorrectionEffect", LG); cc.Brightness = 0.05; cc.Contrast = 0.3; cc.Saturation = 0.5; cc.TintColor = Color3.fromRGB(200, 180, 255); table.insert(rtxObjects, cc)
        local dof = Instance.new("DepthOfFieldEffect", LG); dof.FarIntensity = 0.15; dof.FocusDistance = 20; dof.InFocusRadius = 25; dof.NearIntensity = 0.3; table.insert(rtxObjects, dof)
        local atmo = Instance.new("Atmosphere", LG); atmo.Density = 0.35; atmo.Offset = 0.1; atmo.Color = Color3.fromRGB(199, 199, 199); atmo.Decay = Color3.fromRGB(106, 112, 125); atmo.Glare = 0.5; atmo.Haze = 1.5; table.insert(rtxObjects, atmo)
    else
        for _, obj in ipairs(rtxObjects) do if obj and obj.Parent then obj:Destroy() end end
        rtxObjects = {}
        LG.FogEnd = 100000; LG.EnvironmentDiffuseScale = 0; LG.EnvironmentSpecularScale = 0
    end
end
AddSection(GPage, "RTX & Reflections")
AddToggle(GPage, "RTX & Reflections", false, function(s) ApplyRTX(s) end)
AddSlider(GPage, "Fog Distance", 100, 2000, 500, function(v) if State["RTX & Reflections"] then LG.FogEnd = v end end)

--============================================================
-- SCRIPTS
--============================================================
AddSection(SPage, "Loadstring Scripts")
local function AddScriptButton(parent, name, url)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); btn.Text = "Загрузить: " .. name; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.AutoButtonColor = false; btn.ZIndex = 55
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function() smooth(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}) end)
    btn.MouseLeave:Connect(function() smooth(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}) end)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "Загрузка..."
        btn.BackgroundColor3 = GlobalColor
        task.spawn(function()
            local success, err = pcall(function()
                local response = game:HttpGet(url, true)
                local func, loadErr = loadstring(response)
                if func then func() else error(loadErr) end
            end)
            if success then btn.Text = "✅ Успешно!"; btn.BackgroundColor3 = Color3.fromRGB(50, 200, 100); task.wait(2)
            else btn.Text = "❌ Ошибка"; btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); warn("Ошибка: " .. tostring(err)); task.wait(3) end
            btn.Text = "Загрузить: " .. name; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end)
    end)
end
AddScriptButton(SPage, "Universal (Pastebin)", "https://pastebin.com/raw/sgkRrt3c")
AddScriptButton(SPage, "Bhop (Scriptblox)", "https://scriptblox.com/raw/Universal-Script-bhop-script-235517")
AddScriptButton(SPage, "Sword Kill Aura", "https://rawscripts.net/raw/Universal-Script-sword-kill-aura-open-source-241692")
AddScriptButton(SPage, "CFly Invisible", "https://scriptblox.com/raw/Universal-Script-Cfly-invisible-235058")

--============================================================
-- БИНДЫ (ИДЕАЛЬНАЯ СИСТЕМА)
--============================================================
AddSection(BPage, "Создание кнопок")

local ActionList = {}
for n, _ in pairs(State) do table.insert(ActionList, n) end
table.sort(ActionList)

local SelAction = ActionList[1] or "Speed Hack"
local SelLbl = Instance.new("TextLabel", BPage)
SelLbl.Size = UDim2.new(1, 0, 0, 26)
SelLbl.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SelLbl.Text = "Функция: " .. SelAction
SelLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
SelLbl.Font = Enum.Font.Gotham
SelLbl.TextSize = 11
SelLbl.ZIndex = 55
Instance.new("UICorner", SelLbl).CornerRadius = UDim.new(0, 6)

local CycBtn = Instance.new("TextButton", BPage)
CycBtn.Size = UDim2.new(1, 0, 0, 26)
CycBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CycBtn.Text = "Сменить функцию"
CycBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CycBtn.Font = Enum.Font.GothamBold
CycBtn.TextSize = 11
CycBtn.ZIndex = 55
Instance.new("UICorner", CycBtn).CornerRadius = UDim.new(0, 6)
CycBtn.MouseButton1Click:Connect(function()
    if #ActionList == 0 then return end
    local idx = 1
    for i, n in ipairs(ActionList) do if n == SelAction then idx = i end end
    idx = idx + 1
    if idx > #ActionList then idx = 1 end
    SelAction = ActionList[idx]
    SelLbl.Text = "Функция: " .. SelAction
end)

local CrBtn = Instance.new("TextButton", BPage)
CrBtn.Size = UDim2.new(1, 0, 0, 26)
CrBtn.BackgroundColor3 = GlobalColor
CrBtn.Text = "Создать кнопку"
CrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CrBtn.Font = Enum.Font.GothamBold
CrBtn.TextSize = 11
CrBtn.ZIndex = 55
Instance.new("UICorner", CrBtn).CornerRadius = UDim.new(0, 6)

CrBtn.MouseButton1Click:Connect(function()
    local actionName = SelAction
    local actionCallback = Callbacks[actionName] -- Берем сохраненный коллбек

    local existing = SG:FindFirstChild(actionName)
    if existing then existing:Destroy() end

    local m = Instance.new("TextButton", SG)
    m.Name = actionName
    m.Size = UDim2.new(0, 60, 0, 60)
    m.Position = UDim2.new(0.5, math.random(-100,100), 0.5, math.random(-100,100))
    m.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    m.Text = actionName
    m.TextColor3 = Color3.fromRGB(255, 255, 255)
    m.Font = Enum.Font.GothamBold
    m.TextSize = 9
    m.TextWrapped = true
    m.Active = true
    m.AutoButtonColor = false
    m.ZIndex = 200
    Instance.new("UICorner", m).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("UIStroke", m)
    s.Color = GlobalColor
    s.Thickness = 2
    s.ZIndex = 201

    local lockInd = Instance.new("Frame", m)
    lockInd.Size = UDim2.new(0, 8, 0, 8)
    lockInd.Position = UDim2.new(1, -10, 0, 2)
    lockInd.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
    lockInd.Visible = false
    lockInd.ZIndex = 202
    Instance.new("UICorner", lockInd).CornerRadius = UDim.new(1, 0)

    local dg, dP, sP, mv, lk, lpF = false, nil, nil, false, false, false
    local lpT = nil
    
    local function isInside(pos)
        local cx = m.AbsolutePosition.X + m.AbsoluteSize.X/2
        local cy = m.AbsolutePosition.Y + m.AbsoluteSize.Y/2
        local r = math.min(m.AbsoluteSize.X, m.AbsoluteSize.Y)/2
        local dx, dy = pos.X - cx, pos.Y - cy
        return (dx*dx + dy*dy) <= (r*r)
    end
    
    local function rc()
        m.BackgroundColor3 = lk and Color3.fromRGB(200, 150, 50) or Color3.fromRGB(15, 15, 18)
    end
    
    local function cancelTimer()
        if lpT then task.cancel(lpT); lpT = nil end
    end

    m.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
        if not isInside(i.Position) then return end
        
        dg = true
        mv = false
        lpF = false
        dP = i.Position
        sP = m.Position
        m.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        
        cancelTimer()
        lpT = task.delay(1, function()
            if dg and not mv then
                lk = not lk
                lpF = true
                lockInd.Visible = lk
                rc()
            end
            lpT = nil
        end)
    end)

    m.InputChanged:Connect(function(i)
        if not dg then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        
        local d = i.Position - dP
        if d.Magnitude > 8 then
            mv = true
            cancelTimer()
        end
        
        if lk then return end
        if mv then
            m.Position = UDim2.new(sP.X.Scale, sP.X.Offset + d.X, sP.Y.Scale, sP.Y.Offset + d.Y)
        end
    end)

    m.InputEnded:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
        if not dg then return end
        
        local wM = mv
        local wL = lpF
        local rI = isInside(i.Position)
        
        dg = false
        mv = false
        cancelTimer()
        rc()
        
        if wL then return end
        
        if not wM and rI then
            -- ВЫЗЫВАЕМ ФУНКЦИЮ С КОЛЛБЕКОМ
            ToggleState(actionName, actionCallback)
            m.BackgroundColor3 = GlobalColor
            task.delay(0.15, rc)
        end
    end)

    m.MouseButton2Click:Connect(function()
        lk = not lk
        lockInd.Visible = lk
        rc()
    end)
end)

print("[EBALSUKU] Загружено! Бинды теперь идеальные (с коллбеками), Аим на ближайшего.")
