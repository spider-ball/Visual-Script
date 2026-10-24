-- ============================================================
-- ШАБЛОН ДЛЯ ПРОВЕРКИ ФУНКЦИЙ (Океан Тоггл)
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============ UI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FuncTest"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка (низ по центру)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 340, 0, 36)
btn.Position = UDim2.new(0.5, 0, 1, -6)
btn.AnchorPoint = Vector2.new(0.5, 1)
btn.BackgroundColor3 = Color3.fromRGB(45,90,140)
btn.BorderSizePixel = 0
btn.Text = "СКРЫТЬ / ПОКАЗАТЬ ОКЕАН"
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 13
btn.Parent = screenGui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

-- Консоль (над кнопкой)
local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(0, 340, 0, 100)
logFrame.Position = UDim2.new(0.5, 0, 1, -46)
logFrame.AnchorPoint = Vector2.new(0.5, 1)
logFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
logFrame.BackgroundTransparency = 0.15
logFrame.BorderSizePixel = 0
logFrame.Parent = screenGui
Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 6)

local pad = Instance.new("UIPadding", logFrame)
pad.PaddingTop = UDim.new(0, 6)
pad.PaddingBottom = UDim.new(0, 6)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)

local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, 0, 1, 0)
logText.BackgroundTransparency = 1
logText.Text = "> Готов"
logText.TextColor3 = Color3.fromRGB(180,220,255)
logText.Font = Enum.Font.Code
logText.TextSize = 11
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.Parent = logFrame

-- ============ ЛОГ ============
local lines = {}
local function logClear() lines = {} logText.Text = "" end
local function log(msg)
    table.insert(lines, "> " .. tostring(msg))
    logText.Text = table.concat(lines, "\n")
    print(msg)
end

-- ============================================================
-- >>>>>> ЗАДАЧА <<<<<<
-- ============================================================

-- Переменные состояния для Тоггла (сохраняют статус между нажатиями)
local isOceanHidden = false
local hiddenOceans = {}

local function runTest()
    logClear()
    
    -- Безопасно ищем контейнер с океанами
    local ok, err = pcall(function()
        local oceanContainer = workspace.Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel
        
        if not isOceanHidden then
            -- СКРЫТИЕ
            log("Скрываем океаны...")
            hiddenOceans = {} -- очищаем таблицу перед новым заполнением
            
            for _, obj in ipairs(oceanContainer:GetChildren()) do
                if obj.Name == "Ocean" then
                    table.insert(hiddenOceans, obj) -- сохраняем ссылку
                    obj.Parent = nil -- убираем из мира (визуально исчезает)
                end
            end
            
            isOceanHidden = true
            log("Готово! Скрыто объектов: " .. tostring(#hiddenOceans))
        else
            -- ВОССТАНОВЛЕНИЕ
            log("Восстанавливаем океаны...")
            
            for _, obj in ipairs(hiddenOceans) do
                obj.Parent = oceanContainer -- возвращаем на место
            end
            
            hiddenOceans = {}
            isOceanHidden = false
            log("Готово! Все океаны на месте.")
        end
    end)

    -- Если произошла ошибка (например, путь изменился или объекты удалили)
    if not ok then
        log("Ошибка: " .. tostring(err))
        log("Проверь путь через Dex!")
    end
end

-- ============================================================
-- >>>>>> КОНЕЦ ЗАДАЧИ <<<<<<
-- ============================================================

btn.MouseButton1Click:Connect(function()
    local ok, err = pcall(runTest)
    if not ok then logClear(); log("Ошибка: " .. tostring(err)) end
end)
