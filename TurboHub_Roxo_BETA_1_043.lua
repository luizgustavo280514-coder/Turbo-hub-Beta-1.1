-- Turbo Hub Roxo BETA 1.043 - guia aéreo mobile
-- Rastreamento visual + previsão aproximada do ponto de queda.
-- O voo usa física local e pode não funcionar se o servidor controlar o veículo.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PURPLE = Color3.fromRGB(185, 90, 255)
local PINK = Color3.fromRGB(255, 90, 220)
local WHITE = Color3.fromRGB(245, 235, 255)

-- Limpa versões anteriores
for _, name in ipairs({"TurboHubLoading", "TurboHubRoxo"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end
for _, name in ipairs({
    "TurboHubBallMarker", "TurboHubLongRangeGuide",
    }) do
    local old = Workspace:FindFirstChild(name)
    if old then old:Destroy() end
end

-- Loading screen mais visível
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "TurboHubLoading"
loadingGui.IgnoreGuiInset = true
loadingGui.ResetOnSpawn = false
loadingGui.DisplayOrder = 999
loadingGui.Parent = playerGui

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
bg.BorderSizePixel = 0
bg.Parent = loadingGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 46)
title.Position = UDim2.new(0, 15, 0.5, -75)
title.BackgroundTransparency = 1
title.Text = "TURBO HUB ROXO"
title.TextColor3 = PURPLE
title.TextSize = 26
title.Font = Enum.Font.GothamBold
title.Parent = bg

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -30, 0, 28)
subtitle.Position = UDim2.new(0, 15, 0.5, -30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Iniciando rastreamento visual..."
subtitle.TextColor3 = WHITE
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = bg

local barBack = Instance.new("Frame")
barBack.Size = UDim2.new(0.7, 0, 0, 9)
barBack.Position = UDim2.new(0.15, 0, 0.5, 12)
barBack.BackgroundColor3 = Color3.fromRGB(48, 31, 60)
barBack.BorderSizePixel = 0
barBack.Parent = bg
Instance.new("UICorner", barBack).CornerRadius = UDim.new(1, 0)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = PURPLE
bar.BorderSizePixel = 0
bar.Parent = barBack
Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

local percent = Instance.new("TextLabel")
percent.Size = UDim2.new(1, 0, 0, 24)
percent.Position = UDim2.new(0, 0, 0.5, 28)
percent.BackgroundTransparency = 1
percent.Text = "0%"
percent.TextColor3 = Color3.fromRGB(210, 180, 230)
percent.TextSize = 12
percent.Font = Enum.Font.GothamSemibold
percent.Parent = bg

for i = 1, 100 do
    bar.Size = UDim2.new(i / 100, 0, 1, 0)
    percent.Text = i .. "%"
    if i == 25 then
        subtitle.Text = "Localizando a bola..."
    elseif i == 55 then
        subtitle.Text = "Calculando trajetória..."
    elseif i == 80 then
        subtitle.Text = "Preparando guia visual..."
    end
    task.wait(0.018)
end
task.wait(0.45)
loadingGui:Destroy()

-- Menu
local gui = Instance.new("ScreenGui")
gui.Name = "TurboHubRoxo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Enabled = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(230, 245)
main.Position = UDim2.new(0.03, 0, 0.22, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 13, 31)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local outline = Instance.new("UIStroke", main)
outline.Color = PURPLE
outline.Thickness = 1.5

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -82, 0, 36)
header.Position = UDim2.fromOffset(12, 3)
header.BackgroundTransparency = 1
header.Text = "TURBO HUB • BETA 1.043"
header.TextColor3 = WHITE
header.TextSize = 14
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 28)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(75, 28, 95)
close.Text = "×"
close.TextColor3 = WHITE
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 27)
status.Position = UDim2.fromOffset(10, 38)
status.BackgroundTransparency = 1
status.Text = "Rastreamento visual ativo..."
status.TextColor3 = Color3.fromRGB(210, 180, 230)
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.Parent = main

local function makeButton(label, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 34)
    b.Position = UDim2.fromOffset(10, y)
    b.BackgroundColor3 = Color3.fromRGB(54, 28, 75)
    b.TextColor3 = WHITE
    b.TextSize = 13
    b.Font = Enum.Font.GothamSemibold
    b.Text = label
    b.Parent = main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = PURPLE
    stroke.Transparency = 0.45
    return b
end

local trackButton = makeButton("Rastreamento: LIGADO", 68)
local predictionButton = makeButton("Trajetória visual: LIGADA", 106)
local flightToggleButton = makeButton("Assistente de Voo: DESLIGADO", 144)
local minimizeButton = makeButton("−", 204)

local note = Instance.new("TextLabel")
note.Size = UDim2.new(1, -20, 0, 20)
note.Position = UDim2.fromOffset(10, 222)
note.BackgroundTransparency = 1
note.Text = "Guia aéreo • salto/turbo manual"
note.TextColor3 = Color3.fromRGB(175, 155, 190)
note.TextSize = 10
note.Font = Enum.Font.Gotham
note.Parent = main

-- Inicia recolhido para não cobrir os botões do jogo.
status.Visible = false
trackButton.Visible = false
predictionButton.Visible = false
flightToggleButton.Visible = false
note.Visible = false
header.Visible = false
close.Visible = false
main.Size = UDim2.fromOffset(175, 48)
header.Text = "TURBO HUB • BETA 1.043"
header.Visible = true
header.Size = UDim2.new(1, -42, 1, 0)
header.Position = UDim2.fromOffset(10, 0)
minimizeButton.Visible = true
minimizeButton.Size = UDim2.fromOffset(36, 34)
minimizeButton.Position = UDim2.new(1, -41, 0, 7)
minimizeButton.Text = "ABRIR ☰"

local tracking, prediction, minimized = true, true, true
local flightAssistantEnabled = false
local ballPart -- alvo compartilhado: a bola do jogo
local findBall

-- Indicador aéreo na tela: não aplica forças nem altera a física do veículo.
local airGuide = Instance.new("TextLabel")
airGuide.Name = "TurboHubAirGuide"
airGuide.Size = UDim2.fromOffset(190, 54)
airGuide.Position = UDim2.new(0.5, -95, 0.12, 0)
airGuide.BackgroundColor3 = Color3.fromRGB(20, 13, 31)
airGuide.BackgroundTransparency = 0.12
airGuide.TextColor3 = WHITE
airGuide.TextSize = 17
airGuide.Font = Enum.Font.GothamBold
airGuide.Text = "✈ GUIA AÉREO: OFF"
airGuide.Visible = false
airGuide.Parent = gui
Instance.new("UICorner", airGuide).CornerRadius = UDim.new(0, 10)
local airStroke = Instance.new("UIStroke", airGuide)
airStroke.Color = PURPLE
airStroke.Thickness = 1.5

local flyButton = Instance.new("TextButton")
flyButton.Name = "TurboHubFlyButton"
flyButton.Size = UDim2.fromOffset(118, 44)
flyButton.Position = UDim2.new(1, -150, 0.42, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(54, 28, 75)
flyButton.TextColor3 = WHITE
flyButton.TextSize = 15
flyButton.Font = Enum.Font.GothamBold
flyButton.Text = "✈ GUIA OFF"
flyButton.Visible = false
flyButton.Parent = gui
Instance.new("UICorner", flyButton).CornerRadius = UDim.new(0, 10)
local flyStroke = Instance.new("UIStroke", flyButton)
flyStroke.Color = PURPLE
flyStroke.Thickness = 1.5

local function setAirGuide(enabled)
    flightAssistantEnabled = enabled
    airGuide.Visible = enabled
    flyButton.Text = enabled and "■ GUIA ON" or "✈ GUIA OFF"
    flyButton.BackgroundColor3 = enabled and Color3.fromRGB(110, 35, 125) or Color3.fromRGB(54, 28, 75)
    flightToggleButton.Text = "Assistente aéreo: " .. (enabled and "LIGADO" or "DESLIGADO")
    if enabled then
        status.Text = "Guia aéreo ligado • use os controles do jogo"
        airGuide.Text = "✈ GUIA AÉREA • mire na bola"
    else
        status.Text = "Guia aéreo desligado"
        airGuide.Text = "✈ GUIA AÉREO: OFF"
    end
end

flightToggleButton.Activated:Connect(function()
    setAirGuide(not flightAssistantEnabled)
    flyButton.Visible = flightAssistantEnabled
end)

flyButton.Activated:Connect(function()
    setAirGuide(not flightAssistantEnabled)
end)

local lastPos, lastTime
local trailParts = {}
local connection

findBall = function()
    local cs = Workspace:FindFirstChild("CarSoccer")
    if cs then
        local mv = cs:FindFirstChild("MatchView")
        local folder = mv and mv:FindFirstChild("Ball")
        local part = folder and folder:FindFirstChild("ball")
        if part and part:IsA("BasePart") then return part end
        local free = cs:FindFirstChild("Ball")
        part = free and free:FindFirstChild("ball")
        if part and part:IsA("BasePart") then return part end
        part = cs:FindFirstChild("BallIndicator")
        if part and part:IsA("BasePart") then return part end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.lower(obj.Name) == "ball" then
            return obj
        end
    end
    return nil
end

local function neonPart(name, shape, size)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Material = Enum.Material.Neon
    p.Color = PURPLE
    p.Transparency = 0.15
    p.Shape = shape or Enum.PartType.Block
    p.Size = size or Vector3.new(0.2, 0.2, 1)
    p.Parent = Workspace
    return p
end

local marker = neonPart("TurboHubBallMarker", Enum.PartType.Ball, Vector3.new(2.2, 2.2, 2.2))
marker.Transparency = 0.35
local guideLine = neonPart("TurboHubLongRangeGuide", Enum.PartType.Block, Vector3.new(0.22, 0.22, 1))

local function clearTrail()
    for _, part in ipairs(trailParts) do
        if part and part.Parent then part:Destroy() end
    end
    table.clear(trailParts)
end

local function drawTrajectory(pos, vel)
    clearTrail()
    if not prediction or vel.Magnitude < 2 then return end
    local gravity = Vector3.new(0, -Workspace.Gravity, 0)
    local previous = pos
    for i = 1, 22 do
        local t = i * 0.09
        local nextPos = pos + vel * t + 0.5 * gravity * t * t
        local delta = nextPos - previous
        if delta.Magnitude > 0.1 then
            local seg = neonPart("TurboHubTrajectorySegment", Enum.PartType.Block,
                Vector3.new(0.12, 0.12, delta.Magnitude))
            seg.Color = PINK
            seg.Transparency = 0.22 + i / 32
            seg.CFrame = CFrame.lookAt((previous + nextPos) / 2, nextPos)
            table.insert(trailParts, seg)
        end
        previous = nextPos
    end
end

-- Usa velocidade física quando disponível; fallback para velocidade medida entre amostras.
local function getVelocity(part, pos, now)
    local physical = part.AssemblyLinearVelocity
    if physical and physical.Magnitude > 1 then
        return physical
    end
    if lastPos and lastTime and now > lastTime then
        return (pos - lastPos) / (now - lastTime)
    end
    return Vector3.zero
end

-- O sistema de círculo de pouso foi removido nesta versão.
local function setHidden(hidden)
    -- Mantém somente os elementos de rastreamento visual.
end

trackButton.Activated:Connect(function()
    tracking = not tracking
    trackButton.Text = "Rastreamento: " .. (tracking and "LIGADO" or "DESLIGADO")
    if not tracking then
        marker.Transparency = 1
        guideLine.Transparency = 1
        setHidden(true)
    end
end)

predictionButton.Activated:Connect(function()
    prediction = not prediction
    predictionButton.Text = "Trajetória visual: " .. (prediction and "LIGADA" or "DESLIGADA")
    if not prediction then
        clearTrail()
        setHidden(true)
    end
end)

minimizeButton.Activated:Connect(function()
    minimized = not minimized
    status.Visible = not minimized
    trackButton.Visible = not minimized
    predictionButton.Visible = not minimized
    flightToggleButton.Visible = not minimized
    note.Visible = not minimized
    close.Visible = not minimized

    main.Size = minimized and UDim2.fromOffset(175, 48) or UDim2.fromOffset(230, 245)
    header.Visible = true
    header.Size = minimized and UDim2.new(1, -42, 1, 0) or UDim2.new(1, -82, 0, 36)
    header.Position = minimized and UDim2.fromOffset(10, 0) or UDim2.fromOffset(12, 3)
    header.Text = "TURBO HUB • BETA 1.043"

    if minimized then
        minimizeButton.Text = "ABRIR ☰"
        minimizeButton.Size = UDim2.fromOffset(36, 34)
        minimizeButton.Position = UDim2.new(1, -41, 0, 7)
    else
        minimizeButton.Text = "−"
        minimizeButton.Size = UDim2.fromOffset(30, 28)
        minimizeButton.Position = UDim2.new(1, -75, 0, 5)
    end
end)

local function cleanup()
    if connection then connection:Disconnect() end
    clearTrail()
    for _, part in ipairs({marker, guideLine, }) do
        if part and part.Parent then part:Destroy() end
    end
end

close.Activated:Connect(function()
    setAirGuide(false)
    cleanup()
    gui:Destroy()
end)
gui.Destroying:Connect(cleanup)

local elapsed = 0
connection = RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.06 then return end
    elapsed = 0

    if not ballPart or not ballPart.Parent then
        ballPart = findBall()
        lastPos, lastTime = nil, nil
    end
    if not ballPart then
        status.Text = "Bola não encontrada • procurando..."
        marker.Transparency = 1
        guideLine.Transparency = 1
        setHidden(true)
        clearTrail()
        return
    end

    local now = os.clock()
    local pos = ballPart.Position
    local vel = getVelocity(ballPart, pos, now)
    local char = player.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    local distance = root and math.floor((pos - root.Position).Magnitude) or 0
    status.Text = "Bola detectada • " .. distance .. " studs"

    if flightAssistantEnabled then
        local camera = Workspace.CurrentCamera
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local airborne = humanoid and humanoid.FloorMaterial == Enum.Material.Air
        local phase = airborne and "NO AR" or (distance < 45 and "PREPARE" or "PRONTO")
        if camera and root then
            local screenPoint, onScreen = camera:WorldToViewportPoint(pos)
            local dx = screenPoint.X - camera.ViewportSize.X / 2
            local dy = screenPoint.Y - camera.ViewportSize.Y / 2
            local direction = "⬆"
            if math.abs(dx) > math.abs(dy) then
                direction = dx > 0 and "➡" or "⬅"
            elseif dy > 0 then
                direction = "⬇"
            end
            if not onScreen then direction = direction .. " FORA" end
            local prompt = airborne and "AJUSTE DIREÇÃO" or "SALTO + TURBO"
            airGuide.Text = "✈ " .. phase .. "  " .. direction .. "\n" .. prompt .. " • " .. distance .. " studs"
        else
            airGuide.Text = "✈ AGUARDANDO CÂMERA..."
        end
    end

    if tracking then
        marker.Transparency = 0.35
        marker.Position = pos
        if root and root:IsA("BasePart") then
            local startPos = root.Position + Vector3.new(0, 1.5, 0)
            local delta = pos - startPos
            if delta.Magnitude > 0.5 then
                guideLine.Transparency = 0.18
                guideLine.Size = Vector3.new(0.22, 0.22, delta.Magnitude)
                guideLine.CFrame = CFrame.lookAt((startPos + pos) / 2, pos)
            else
                guideLine.Transparency = 1
            end
        else
            guideLine.Transparency = 1
        end
    else
        marker.Transparency = 1
        guideLine.Transparency = 1
    end

    if tracking and prediction then
        drawTrajectory(pos, vel)
    else
        clearTrail()
    end

    lastPos, lastTime = pos, now
end)
