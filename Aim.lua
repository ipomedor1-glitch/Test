local c = workspace.CurrentCamera
local p = game:GetService("Players").LocalPlayer
local e = false -- ПО УМОЛЧАНИЮ ВЫКЛЮЧЕН
local currentFOV = 300
local ignoreList = {} -- Список игроков для игнора
local selectedColor = Color3.fromRGB(255, 200, 50) -- Текущий цвет

-- ===== ЗАГРУЗКА ИГНОР-ЛИСТА ИЗ ДАННЫХ =====
local function loadIgnoreList()
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(p:GetAttribute("IgnoreList") or "[]")
    end)
    if success and type(data) == "table" then
        ignoreList = data
    else
        ignoreList = {}
    end
end

-- ===== СОХРАНЕНИЕ ИГНОР-ЛИСТА =====
local function saveIgnoreList()
    local success = pcall(function()
        p:SetAttribute("IgnoreList", game:GetService("HttpService"):JSONEncode(ignoreList))
    end)
end

-- Загружаем игнор-лист при запуске
loadIgnoreList()

-- ===== ФУНКЦИЯ ДЛЯ ПРОВЕРКИ ИГНОРА =====
local function isIgnored(playerName)
    if not playerName then return false end
    for _, name in ipairs(ignoreList) do
        if string.lower(name) == string.lower(playerName) then
            return true
        end
    end
    return false
end

-- Клавиша E (синхронизация с GUI)
game:GetService("UserInputService").InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.E then
        e = not e
        print(e and "AIM ON" or "AIM OFF")
        if updateAimUI then updateAimUI() end
    end
end)

-- Основной аим с игнор-листом
game:GetService("RunService").RenderStepped:Connect(function()
    if not e then return end
    
    local ct = nil
    local closestDistance = math.huge
    local centerScreen = c.ViewportSize / 2
    
    for _, v in ipairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") and v ~= p.Character and v.Humanoid.Health > 0 then
            -- Проверяем игнор-лист
            local playerName = v.Name
            if isIgnored(playerName) then
                continue
            end
            
            local pos, on = c:WorldToViewportPoint(v.Head.Position)
            if on then
                local distanceFromCenter = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitude
                
                if distanceFromCenter < currentFOV then
                    if distanceFromCenter < closestDistance then
                        local ray = Ray.new(c.CFrame.Position, (v.Head.Position - c.CFrame.Position).Unit * 1000)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {p.Character, v.Head})
                        if hit and hit:IsDescendantOf(v) then
                            closestDistance = distanceFromCenter
                            ct = v
                        end
                    end
                end
            end
        end
    end
    
    if ct then
        local hp = ct.Head.Position
        c.CFrame = CFrame.lookAt(c.CFrame.Position, c.CFrame.Position + (hp - c.CFrame.Position).Unit)
    end
end)

-- ===== GUI МЕНЮ =====
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "AimMenu"
screenGui.ResetOnSpawn = false

-- Цвета темы
local colors = {
    darkRed = Color3.fromRGB(60, 10, 10),
    gold = Color3.fromRGB(255, 200, 50),
    darkGold = Color3.fromRGB(180, 140, 30),
    red = Color3.fromRGB(200, 30, 30),
    dark = Color3.fromRGB(20, 5, 5),
    text = Color3.fromRGB(255, 220, 150),
    border = Color3.fromRGB(200, 150, 50),
    green = Color3.fromRGB(0, 200, 50)
}

-- ===== FOV КРУГ =====
local fovCircle = Instance.new("Frame")
fovCircle.Parent = screenGui
fovCircle.Size = UDim2.new(0, currentFOV, 0, currentFOV)
fovCircle.Position = UDim2.new(0.5, -currentFOV/2, 0.5, -currentFOV/2)
fovCircle.BackgroundTransparency = 1
fovCircle.ZIndex = 0
fovCircle.Visible = false

local circleBorder = Instance.new("Frame")
circleBorder.Parent = fovCircle
circleBorder.Size = UDim2.new(1, 0, 1, 0)
circleBorder.Position = UDim2.new(0, 0, 0, 0)
circleBorder.BackgroundTransparency = 0.85
circleBorder.BackgroundColor3 = colors.gold
circleBorder.BorderSizePixel = 3
circleBorder.BorderColor3 = colors.gold
circleBorder.ZIndex = 0

local circleCorner = Instance.new("UICorner")
circleCorner.Parent = circleBorder
circleCorner.CornerRadius = UDim.new(1, 0)

-- Текст FOV
local fovText = Instance.new("TextLabel")
fovText.Parent = screenGui
fovText.Size = UDim2.new(0, 100, 0, 30)
fovText.Position = UDim2.new(0.5, -50, 0.5, -170)
fovText.BackgroundTransparency = 1
fovText.Text = "FOV: " .. currentFOV
fovText.TextColor3 = colors.gold
fovText.TextScaled = true
fovText.Font = Enum.Font.GothamBold
fovText.ZIndex = 1
fovText.Visible = false

-- ===== ПЛАВАЮЩАЯ КНОПКА AIM =====
local aimButton = Instance.new("TextButton")
aimButton.Parent = screenGui
aimButton.Size = UDim2.new(0, 75, 0, 75)
aimButton.Position = UDim2.new(1, -95, 0.5, -37)
aimButton.BackgroundColor3 = Color3.fromRGB(30, 5, 5)
aimButton.BackgroundTransparency = 0.2
aimButton.BorderSizePixel = 3
aimButton.BorderColor3 = colors.red
aimButton.Text = "❌\nAIM"
aimButton.TextColor3 = colors.text
aimButton.TextScaled = true
aimButton.Font = Enum.Font.GothamBold
aimButton.ZIndex = 10

local aimBtnCorner = Instance.new("UICorner")
aimBtnCorner.Parent = aimButton
aimBtnCorner.CornerRadius = UDim.new(1, 0)

-- ===== КНОПКА МЕНЮ =====
local menuButton = Instance.new("TextButton")
menuButton.Parent = screenGui
menuButton.Size = UDim2.new(0, 55, 0, 55)
menuButton.Position = UDim2.new(0, 15, 0.5, -27)
menuButton.BackgroundColor3 = colors.dark
menuButton.BackgroundTransparency = 0.2
menuButton.BorderSizePixel = 2
menuButton.BorderColor3 = colors.gold
menuButton.Text = "⚙️"
menuButton.TextColor3 = colors.gold
menuButton.TextScaled = true
menuButton.Font = Enum.Font.GothamBold
menuButton.ZIndex = 9

local menuBtnCorner = Instance.new("UICorner")
menuBtnCorner.Parent = menuButton
menuBtnCorner.CornerRadius = UDim.new(1, 0)

-- ===== ОСНОВНОЕ МЕНЮ =====
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 380, 0, 480)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 3, 3)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = colors.gold
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.ZIndex = 5

local menuCorner = Instance.new("UICorner")
menuCorner.Parent = mainFrame
menuCorner.CornerRadius = UDim.new(0, 15)

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = colors.darkRed
titleLabel.BackgroundTransparency = 0.3
titleLabel.Text = "⚜️ AIM CONTROL ⚜️"
titleLabel.TextColor3 = colors.gold
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.BorderSizePixel = 0
titleLabel.ZIndex = 6

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = mainFrame
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = colors.red
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 6

-- Вкладки
local tabFrame = Instance.new("Frame")
tabFrame.Parent = mainFrame
tabFrame.Size = UDim2.new(1, 0, 0, 35)
tabFrame.Position = UDim2.new(0, 0, 0, 45)
tabFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
tabFrame.BackgroundTransparency = 0.3
tabFrame.BorderSizePixel = 0
tabFrame.ZIndex = 6

-- Кнопки вкладок
local tab1 = Instance.new("TextButton")
tab1.Parent = tabFrame
tab1.Size = UDim2.new(0, 120, 1, -4)
tab1.Position = UDim2.new(0, 10, 0, 2)
tab1.BackgroundColor3 = colors.darkRed
tab1.BackgroundTransparency = 0.2
tab1.BorderSizePixel = 2
tab1.BorderColor3 = colors.gold
tab1.Text = "🎯 MAIN"
tab1.TextColor3 = colors.gold
tab1.TextScaled = true
tab1.Font = Enum.Font.GothamBold
tab1.ZIndex = 7

local tab1Corner = Instance.new("UICorner")
tab1Corner.Parent = tab1
tab1Corner.CornerRadius = UDim.new(0, 5)

local tab2 = Instance.new("TextButton")
tab2.Parent = tabFrame
tab2.Size = UDim2.new(0, 120, 1, -4)
tab2.Position = UDim2.new(0, 140, 0, 2)
tab2.BackgroundColor3 = colors.dark
tab2.BackgroundTransparency = 0.2
tab2.BorderSizePixel = 2
tab2.BorderColor3 = colors.darkGold
tab2.Text = "🚫 IGNORE"
tab2.TextColor3 = colors.text
tab2.TextScaled = true
tab2.Font = Enum.Font.GothamBold
tab2.ZIndex = 7

local tab2Corner = Instance.new("UICorner")
tab2Corner.Parent = tab2
tab2Corner.CornerRadius = UDim.new(0, 5)

-- ===== ВКЛАДКА 1 (MAIN) =====
local mainTab = Instance.new("Frame")
mainTab.Parent = mainFrame
mainTab.Size = UDim2.new(1, 0, 1, -80)
mainTab.Position = UDim2.new(0, 0, 0, 80)
mainTab.BackgroundTransparency = 1
mainTab.ZIndex = 6

-- Разделитель
local divider2 = Instance.new("Frame")
divider2.Parent = mainTab
divider2.Size = UDim2.new(0.9, 0, 0, 2)
divider2.Position = UDim2.new(0.05, 0, 0, 0)
divider2.BackgroundColor3 = colors.gold
divider2.BackgroundTransparency = 0.5
divider2.BorderSizePixel = 0

-- Цветовые кнопки
local colorLabels2 = {"Золот", "Красн", "Оранж", "Белы", "Фиол"}
local colorValues2 = {
    Color3.fromRGB(255, 200, 50),
    Color3.fromRGB(200, 30, 30),
    Color3.fromRGB(255, 150, 30),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(150, 50, 200)
}

for i = 1, 5 do
    local colorBtn = Instance.new("TextButton")
    colorBtn.Parent = mainTab
    colorBtn.Size = UDim2.new(0, 50, 0, 50)
    colorBtn.Position = UDim2.new(0, 15 + (i-1) * 60, 0, 15)
    colorBtn.BackgroundColor3 = colorValues2[i]
    colorBtn.BackgroundTransparency = 0.2
    colorBtn.BorderSizePixel = 2
    colorBtn.BorderColor3 = colors.gold
    colorBtn.Text = colorLabels2[i]
    colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorBtn.TextScaled = true
    colorBtn.Font = Enum.Font.Gotham
    colorBtn.ZIndex = 7
    
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.Parent = colorBtn
    btnCorner2.CornerRadius = UDim.new(1, 0)
    
    colorBtn.MouseButton1Click:Connect(function()
        selectedColor = colorValues2[i]
        circleBorder.BackgroundColor3 = selectedColor
        circleBorder.BorderColor3 = selectedColor
        fovText.TextColor3 = selectedColor
        mainFrame.BorderColor3 = selectedColor
        menuButton.BorderColor3 = selectedColor
        if e then
            aimButton.BorderColor3 = selectedColor
        end
    end)
end

-- Слайдер FOV
local sliderLabel2 = Instance.new("TextLabel")
sliderLabel2.Parent = mainTab
sliderLabel2.Size = UDim2.new(0, 100, 0, 25)
sliderLabel2.Position = UDim2.new(0, 20, 0, 85)
sliderLabel2.BackgroundTransparency = 1
sliderLabel2.Text = "FOV RADIUS:"
sliderLabel2.TextColor3 = colors.text
sliderLabel2.TextScaled = true
sliderLabel2.Font = Enum.Font.Gotham
sliderLabel2.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel2.ZIndex = 7

local sliderFrame2 = Instance.new("Frame")
sliderFrame2.Parent = mainTab
sliderFrame2.Size = UDim2.new(0, 280, 0, 30)
sliderFrame2.Position = UDim2.new(0, 20, 0, 115)
sliderFrame2.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
sliderFrame2.BackgroundTransparency = 0.5
sliderFrame2.BorderSizePixel = 2
sliderFrame2.BorderColor3 = colors.gold
sliderFrame2.ZIndex = 7

local sliderCorner2 = Instance.new("UICorner")
sliderCorner2.Parent = sliderFrame2
sliderCorner2.CornerRadius = UDim.new(1, 0)

local sliderFill2 = Instance.new("Frame")
sliderFill2.Parent = sliderFrame2
sliderFill2.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill2.BackgroundColor3 = colors.gold
sliderFill2.BackgroundTransparency = 0.3
sliderFill2.BorderSizePixel = 0
sliderFill2.ZIndex = 7

local fillCorner3 = Instance.new("UICorner")
fillCorner3.Parent = sliderFill2
fillCorner3.CornerRadius = UDim.new(1, 0)

local sliderButton2 = Instance.new("TextButton")
sliderButton2.Parent = sliderFill2
sliderButton2.Size = UDim2.new(0, 25, 1, -5)
sliderButton2.Position = UDim2.new(1, -12, 0, 2.5)
sliderButton2.BackgroundColor3 = colors.gold
sliderButton2.BackgroundTransparency = 0.2
sliderButton2.BorderSizePixel = 2
sliderButton2.BorderColor3 = colors.gold
sliderButton2.Text = "◆"
sliderButton2.TextColor3 = colors.gold
sliderButton2.TextScaled = true
sliderButton2.ZIndex = 8

-- Значение FOV
local fovValueLabel2 = Instance.new("TextLabel")
fovValueLabel2.Parent = mainTab
fovValueLabel2.Size = UDim2.new(0, 80, 0, 35)
fovValueLabel2.Position = UDim2.new(0, 130, 0, 155)
fovValueLabel2.BackgroundTransparency = 1
fovValueLabel2.Text = tostring(currentFOV)
fovValueLabel2.TextColor3 = colors.gold
fovValueLabel2.TextScaled = true
fovValueLabel2.Font = Enum.Font.GothamBold
fovValueLabel2.ZIndex = 7

-- Статус AIM
local statusFrame2 = Instance.new("Frame")
statusFrame2.Parent = mainTab
statusFrame2.Size = UDim2.new(0, 180, 0, 40)
statusFrame2.Position = UDim2.new(0.5, -90, 0, 210)
statusFrame2.BackgroundColor3 = Color3.fromRGB(30, 5, 5)
statusFrame2.BackgroundTransparency = 0.3
statusFrame2.BorderSizePixel = 2
statusFrame2.BorderColor3 = colors.red
statusFrame2.ZIndex = 7

local statusCorner2 = Instance.new("UICorner")
statusCorner2.Parent = statusFrame2
statusCorner2.CornerRadius = UDim.new(0, 8)

local statusText2 = Instance.new("TextLabel")
statusText2.Parent = statusFrame2
statusText2.Size = UDim2.new(1, 0, 1, 0)
statusText2.BackgroundTransparency = 1
statusText2.Text = "🔴 AIM: OFF"
statusText2.TextColor3 = colors.text
statusText2.TextScaled = true
statusText2.Font = Enum.Font.GothamBold
statusText2.ZIndex = 8

-- Кнопка AIM в меню
local menuAimBtn = Instance.new("TextButton")
menuAimBtn.Parent = mainTab
menuAimBtn.Size = UDim2.new(0, 160, 0, 45)
menuAimBtn.Position = UDim2.new(0.5, -80, 0, 270)
menuAimBtn.BackgroundColor3 = colors.darkRed
menuAimBtn.BackgroundTransparency = 0.2
menuAimBtn.BorderSizePixel = 2
menuAimBtn.BorderColor3 = colors.red
menuAimBtn.Text = "🔴 TURN ON"
menuAimBtn.TextColor3 = colors.text
menuAimBtn.TextScaled = true
menuAimBtn.Font = Enum.Font.GothamBold
menuAimBtn.ZIndex = 7

local menuAimCorner = Instance.new("UICorner")
menuAimCorner.Parent = menuAimBtn
menuAimCorner.CornerRadius = UDim.new(0, 10)

-- ===== ВКЛАДКА 2 (IGNORE) =====
local ignoreTab = Instance.new("Frame")
ignoreTab.Parent = mainFrame
ignoreTab.Size = UDim2.new(1, 0, 1, -80)
ignoreTab.Position = UDim2.new(0, 0, 0, 80)
ignoreTab.BackgroundTransparency = 1
ignoreTab.ZIndex = 6
ignoreTab.Visible = false

-- Поле ввода ника
local inputLabel = Instance.new("TextLabel")
inputLabel.Parent = ignoreTab
inputLabel.Size = UDim2.new(0, 100, 0, 30)
inputLabel.Position = UDim2.new(0, 20, 0, 20)
inputLabel.BackgroundTransparency = 1
inputLabel.Text = "Имя игрока:"
inputLabel.TextColor3 = colors.text
inputLabel.TextScaled = true
inputLabel.Font = Enum.Font.Gotham
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.ZIndex = 7

local inputBox = Instance.new("TextBox")
inputBox.Parent = ignoreTab
inputBox.Size = UDim2.new(0, 200, 0, 35)
inputBox.Position = UDim2.new(0, 130, 0, 17)
inputBox.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
inputBox.BackgroundTransparency = 0.3
inputBox.BorderSizePixel = 2
inputBox.BorderColor3 = colors.gold
inputBox.Text = ""
inputBox.PlaceholderText = "Введите ник..."
inputBox.TextColor3 = colors.text
inputBox.TextScaled = true
inputBox.Font = Enum.Font.Gotham
inputBox.ZIndex = 7
inputBox.ClearTextOnFocus = true

local inputCorner2 = Instance.new("UICorner")
inputCorner2.Parent = inputBox
inputCorner2.CornerRadius = UDim.new(0, 8)

-- Кнопка добавления
local addIgnoreBtn = Instance.new("TextButton")
addIgnoreBtn.Parent = ignoreTab
addIgnoreBtn.Size = UDim2.new(0, 50, 0, 35)
addIgnoreBtn.Position = UDim2.new(0, 340, 0, 17)
addIgnoreBtn.BackgroundColor3 = colors.darkRed
addIgnoreBtn.BackgroundTransparency = 0.2
addIgnoreBtn.BorderSizePixel = 2
addIgnoreBtn.BorderColor3 = colors.gold
addIgnoreBtn.Text = "➕"
addIgnoreBtn.TextColor3 = colors.gold
addIgnoreBtn.TextScaled = true
addIgnoreBtn.Font = Enum.Font.GothamBold
addIgnoreBtn.ZIndex = 7

local addCorner2 = Instance.new("UICorner")
addCorner2.Parent = addIgnoreBtn
addCorner2.CornerRadius = UDim.new(0, 8)

-- Список игнорируемых
local ignoreTitle = Instance.new("TextLabel")
ignoreTitle.Parent = ignoreTab
ignoreTitle.Size = UDim2.new(0, 200, 0, 25)
ignoreTitle.Position = UDim2.new(0, 20, 0, 70)
ignoreTitle.BackgroundTransparency = 1
ignoreTitle.Text = "🚫 Игнорируемые игроки:"
ignoreTitle.TextColor3 = colors.text
ignoreTitle.TextScaled = true
ignoreTitle.Font = Enum.Font.Gotham
ignoreTitle.TextXAlignment = Enum.TextXAlignment.Left
ignoreTitle.ZIndex = 7

local ignoreListFrame2 = Instance.new("Frame")
ignoreListFrame2.Parent = ignoreTab
ignoreListFrame2.Size = UDim2.new(0, 330, 0, 120)
ignoreListFrame2.Position = UDim2.new(0, 20, 0, 100)
ignoreListFrame2.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
ignoreListFrame2.BackgroundTransparency = 0.3
ignoreListFrame2.BorderSizePixel = 2
ignoreListFrame2.BorderColor3 = colors.darkGold
ignoreListFrame2.ZIndex = 7
ignoreListFrame2.ClipsDescendants = true

local ignoreCorner2 = Instance.new("UICorner")
ignoreCorner2.Parent = ignoreListFrame2
ignoreCorner2.CornerRadius = UDim.new(0, 5)

local ignoreText2 = Instance.new("TextLabel")
ignoreText2.Parent = ignoreListFrame2
ignoreText2.Size = UDim2.new(1, -10, 1, 0)
ignoreText2.Position = UDim2.new(0, 5, 0, 0)
ignoreText2.BackgroundTransparency = 1
ignoreText2.Text = "Никто не игнорируется"
ignoreText2.TextColor3 = colors.text
ignoreText2.TextScaled = true
ignoreText2.Font = Enum.Font.Gotham
ignoreText2.TextXAlignment = Enum.TextXAlignment.Left
ignoreText2.TextYAlignment = Enum.TextYAlignment.Top
ignoreText2.ZIndex = 8

-- Кнопка очистки
local clearIgnoreBtn2 = Instance.new("TextButton")
clearIgnoreBtn2.Parent = ignoreTab
clearIgnoreBtn2.Size = UDim2.new(0, 120, 0, 35)
clearIgnoreBtn2.Position = UDim2.new(0, 230, 0, 235)
clearIgnoreBtn2.BackgroundColor3 = colors.darkRed
clearIgnoreBtn2.BackgroundTransparency = 0.2
clearIgnoreBtn2.BorderSizePixel = 2
clearIgnoreBtn2.BorderColor3 = colors.red
clearIgnoreBtn2.Text = "🧹 Очистить все"
clearIgnoreBtn2.TextColor3 = colors.text
clearIgnoreBtn2.TextScaled = true
clearIgnoreBtn2.Font = Enum.Font.GothamBold
clearIgnoreBtn2.ZIndex = 7
clearIgnoreBtn2.Visible = false

local clearCorner2 = Instance.new("UICorner")
clearCorner2.Parent = clearIgnoreBtn2
clearCorner2.CornerRadius = UDim.new(0, 8)

-- ===== ФУНКЦИИ ИГНОР-ЛИСТА =====
local function updateIgnoreListUI()
    if #ignoreList == 0 then
        ignoreText2.Text = "Никто не игнорируется"
        clearIgnoreBtn2.Visible = false
    else
        local text = ""
        for i, name in ipairs(ignoreList) do
            text = text .. "• " .. name
            if i < #ignoreList then text = text .. "\n" end
        end
        ignoreText2.Text = text
        clearIgnoreBtn2.Visible = true
    end
    saveIgnoreList()
end

-- Добавление в игнор
addIgnoreBtn.MouseButton1Click:Connect(function()
    local name = inputBox.Text
    if name and name ~= "" then
        if not isIgnored(name) then
            table.insert(ignoreList, name)
            updateIgnoreListUI()
            inputBox.Text = ""
            print("🔇 Игнорируется: " .. name)
            -- Уведомление
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "🔇 Игнор-лист",
                Text = "Игрок " .. name .. " добавлен в игнор!",
                Duration = 3
            })
        else
            print("⚠️ Уже в игнор-листе: " .. name)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⚠️ Внимание",
                Text = "Игрок " .. name .. " уже в игнор-листе!",
                Duration = 3
            })
        end
    end
end)

-- Enter в поле ввода
inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local name = inputBox.Text
        if name and name ~= "" then
            if not isIgnored(name) then
                table.insert(ignoreList, name)
                updateIgnoreListUI()
                inputBox.Text = ""
                print("🔇 Игнорируется: " .. name)
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🔇 Игнор-лист",
                    Text = "Игрок " .. name .. " добавлен в игнор!",
                    Duration = 3
                })
            else
                print("⚠️ Уже в игнор-листе: " .. name)
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "⚠️ Внимание",
                    Text = "Игрок " .. name .. " уже в игнор-листе!",
                    Duration = 3
                })
            end
        end
    end
end)

-- Очистка игнор-листа
clearIgnoreBtn2.MouseButton1Click:Connect(function()
    ignoreList = {}
    updateIgnoreListUI()
    print("🧹 Игнор-лист очищен")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🧹 Игнор-лист",
        Text = "Список игнора полностью очищен!",
        Duration = 3
    })
end)

-- ===== ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК =====
tab1.MouseButton1Click:Connect(function()
    mainTab.Visible = true
    ignoreTab.Visible = false
    tab1.BackgroundColor3 = colors.darkRed
    tab1.BorderColor3 = colors.gold
    tab1.TextColor3 = colors.gold
    tab2.BackgroundColor3 = colors.dark
    tab2.BorderColor3 = colors.darkGold
    tab2.TextColor3 = colors.text
end)

tab2.MouseButton1Click:Connect(function()
    mainTab.Visible = false
    ignoreTab.Visible = true
    tab2.BackgroundColor3 = colors.darkRed
    tab2.BorderColor3 = colors.gold
    tab2.TextColor3 = colors.gold
    tab1.BackgroundColor3 = colors.dark
    tab1.BorderColor3 = colors.darkGold
    tab1.TextColor3 = colors.text
end)

-- ===== ФУНКЦИЯ ОБНОВЛЕНИЯ UI =====
local function updateAimUI()
    if e then
        aimButton.Text = "✅\nAIM"
        aimButton.BorderColor3 = selectedColor
        aimButton.BackgroundColor3 = colors.darkRed
        fovCircle.Visible = true
        fovText.Visible = true
        statusText2.Text = "🟢 AIM: ON"
        statusFrame2.BorderColor3 = colors.green
        statusFrame2.BackgroundColor3 = colors.darkRed
        menuAimBtn.Text = "🟢 TURN OFF"
        menuAimBtn.BorderColor3 = selectedColor
    else
        aimButton.Text = "❌\nAIM"
        aimButton.BorderColor3 = colors.red
        aimButton.BackgroundColor3 = Color3.fromRGB(30, 5, 5)
        fovCircle.Visible = false
        fovText.Visible = false
        statusText2.Text = "🔴 AIM: OFF"
        statusFrame2.BorderColor3 = colors.red
        statusFrame2.BackgroundColor3 = Color3.fromRGB(30, 5, 5)
        menuAimBtn.Text = "🔴 TURN ON"
        menuAimBtn.BorderColor3 = colors.red
    end
end

-- ===== ПЕРЕТАСКИВАНИЕ МЕНЮ =====
local menuDragStart, menuDragStartPos
local isDraggingMenu = false

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if mainFrame.Visible then
            isDraggingMenu = true
            menuDragStart = input.Position
            menuDragStartPos = mainFrame.Position
        end
    end
end)

titleLabel.InputChanged:Connect(function(input)
    if isDraggingMenu and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - menuDragStart
        local newX = math.clamp(menuDragStartPos.X.Offset + delta.X, -mainFrame.AbsoluteSize.X/2, screenGui.AbsoluteSize.X - mainFrame.AbsoluteSize.X/2)
        local newY = math.clamp(menuDragStartPos.Y.Offset + delta.Y, 0, screenGui.AbsoluteSize.Y - mainFrame.AbsoluteSize.Y)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)

titleLabel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingMenu = false
        menuDragStart = nil
    end
end)

-- ===== ПЕРЕТАСКИВАНИЕ ПЛАВАЮЩЕЙ КНОПКИ AIM =====
local aimDragStart, aimDragStartPos
aimButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimDragStart = input.Position
        aimDragStartPos = aimButton.Position
    end
end)

aimButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if aimDragStart then
            local delta = input.Position - aimDragStart
            local newX = math.clamp(aimDragStartPos.X.Offset + delta.X, 0, screenGui.AbsoluteSize.X - 75)
            local newY = math.clamp(aimDragStartPos.Y.Offset + delta.Y, 0, screenGui.AbsoluteSize.Y - 75)
            aimButton.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

aimButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimDragStart = nil
    end
end)

-- ===== ПЕРЕТАСКИВАНИЕ КНОПКИ МЕНЮ =====
local menuBtnDragStart, menuBtnDragStartPos
menuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuBtnDragStart = input.Position
        menuBtnDragStartPos = menuButton.Position
    end
end)

menuButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if menuBtnDragStart then
            local delta = input.Position - menuBtnDragStart
            local newX = math.clamp(menuBtnDragStartPos.X.Offset + delta.X, 0, screenGui.AbsoluteSize.X - 55)
            local newY = math.clamp(menuBtnDragStartPos.Y.Offset + delta.Y, 0, screenGui.AbsoluteSize.Y - 55)
            menuButton.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

menuButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuBtnDragStart = nil
    end
end)

-- ===== ПЕРЕКЛЮЧЕНИЕ AIM =====
local function toggleAim()
    e = not e
    print(e and "AIM ON" or "AIM OFF")
    updateAimUI()
    -- Уведомление при переключении
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = e and "🎯 AIM" or "🎯 AIM",
        Text = e and "✅ AIM ВКЛЮЧЕН!" or "❌ AIM ВЫКЛЮЧЕН!",
        Duration = 2
    })
end

aimButton.MouseButton1Click:Connect(toggleAim)
aimButton.TouchTap:Connect(toggleAim)
menuAimBtn.MouseButton1Click:Connect(toggleAim)
menuAimBtn.TouchTap:Connect(toggleAim)

-- ===== ОТКРЫТИЕ/ЗАКРЫТИЕ МЕНЮ =====
local menuOpen = false

menuButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    mainFrame.Visible = menuOpen
    updateAimUI()
end)

menuButton.TouchTap:Connect(function()
    menuOpen = not menuOpen
    mainFrame.Visible = menuOpen
    updateAimUI()
end)

closeBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    mainFrame.Visible = false
end)

closeBtn.TouchTap:Connect(function()
    menuOpen = false
    mainFrame.Visible = false
end)

-- ===== СЛАЙДЕР FOV =====
local dragging = false

sliderButton2.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

sliderButton2.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

sliderButton2.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local absPos = input.Position.X - sliderFrame2.AbsolutePosition.X
        local newWidth = math.clamp(absPos / sliderFrame2.AbsoluteSize.X, 0, 1)
        sliderFill2.Size = UDim2.new(newWidth, 0, 1, 0)
        currentFOV = math.floor(50 + newWidth * 350)
        fovValueLabel2.Text = tostring(currentFOV)
        fovText.Text = "FOV: " .. currentFOV
        fovCircle.Size = UDim2.new(0, currentFOV, 0, currentFOV)
        fovCircle.Position = UDim2.new(0.5, -currentFOV/2, 0.5, -currentFOV/2)
    end
end)

-- ===== ИНИЦИАЛИЗАЦИЯ =====
updateAimUI()
updateIgnoreListUI()

-- Уведомление при запуске
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "⚜️ AIM CONTROL",
    Text = "Скрипт загружен! Нажми E или кнопку AIM",
    Duration = 4
})

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "📱 Управление",
    Text = "Кнопка AIM ❌/✅ | ⚙️ Меню | E - переключение",
    Duration = 3
})

print("✅ AIM загружен! По умолчанию: ВЫКЛЮЧЕН")
print("🎯 FOV круг скрыт до включения AIM")
print("⚜️ Стиль: Темный Красный + Золотой")
print("📱 2 вкладки: MAIN и IGNORE")
print("⌨️ Клавиша E синхронизирована с GUI")
print("🔇 Игнор-лист сохраняется автоматически")
