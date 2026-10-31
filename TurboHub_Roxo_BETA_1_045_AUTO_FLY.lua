-- TURBO HUB ROXO BETA 1.045 - AUTO FLY BALL INTEGRADO
-- Carrega a base do TurboHub Roxo e adiciona o botão Auto Fly no menu original.

local BASE_URL = "https://raw.githubusercontent.com/luizgustavo280514-coder/Turbo-hub-Beta-1-0/main/TurboHub_Roxo_BETA_1_0_MENU_FIX.lua"

local ok, err = pcall(function()
    local source = game:HttpGet(BASE_URL)
    assert(type(source) == "string" and #source > 1000, "Não foi possível baixar a base do TurboHub")
    local chunk = loadstring(source)
    assert(chunk, "Erro ao compilar a base do TurboHub")
    chunk()
end)

if not ok then
    warn("[TurboHub BETA 1.045] Falha ao iniciar a base: " .. tostring(err))
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui
local main
for _ = 1, 100 do
    gui = playerGui:FindFirstChild("TurboHubRoxo")
    main = gui and gui:FindFirstChildOfClass("Frame")
    if main then break end
    task.wait(0.1)
end

if not main then
    warn("[TurboHub BETA 1.045] Menu original não encontrado.")
    return
end

-- Evita duplicar o botão se o arquivo for executado novamente.
local oldButton = main:FindFirstChild("TurboHubAutoFlyButton")
if oldButton then oldButton:Destroy() end

-- Mantém o menu compacto e encaixa o novo botão antes do botão minimizar.
main.ClipsDescendants = true

local header = main:FindFirstChildWhichIsA("TextLabel")
if header and string.find(string.upper(header.Text), "TURBO HUB") then
    header.Text = "TURBO HUB • BETA 1.045"
end

local note = main:FindFirstChildWhichIsA("TextLabel")
if note and note ~= header then
    note.Visible = false
    note.Size = UDim2.fromOffset(0, 0)
end

local button = Instance.new("TextButton")
button.Name = "TurboHubAutoFlyButton"
button.Size = UDim2.new(1, -20, 0, 20)
button.Position = UDim2.fromOffset(10, 144)
button.BackgroundColor3 = Color3.fromRGB(54, 28, 75)
button.Text = "AUTO FLY BALL: DESLIGADO"
button.TextColor3 = Color3.fromRGB(245, 235, 255)
button.TextSize = 11
button.Font = Enum.Font.GothamBold
button.AutoButtonColor = true
button.ZIndex = 20
button.Parent = main
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(185, 90, 255)
outline.Transparency = 0.35
outline.Parent = button

local enabled = false
local flyConnection
local velocity
local attachment
local SPEED = 58
local HEIGHT = 6
local STOP_DISTANCE = 5

local function getBall()
    local soccer = workspace:FindFirstChild("CarSoccer")
    if soccer then
        local matchView = soccer:FindFirstChild("MatchView")
        local folder = matchView and matchView:FindFirstChild("Ball")
        local part = folder and folder:FindFirstChild("ball")
        if part and part:IsA("BasePart") then return part end

        local freeFolder = soccer:FindFirstChild("Ball")
        part = freeFolder and freeFolder:FindFirstChild("ball")
        if part and part:IsA("BasePart") then return part end

        part = soccer:FindFirstChild("BallIndicator")
        if part and part:IsA("BasePart") then return part end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.lower(obj.Name) == "ball" then
            return obj
        end
    end
    return nil
end

local function stopFly()
    enabled = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if velocity then
        velocity:Destroy()
        velocity = nil
    end
    if attachment then
        attachment:Destroy()
        attachment = nil
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then root.AssemblyLinearVelocity = Vector3.zero end
    if button and button.Parent then
        button.Text = "AUTO FLY BALL: DESLIGADO"
        button.BackgroundColor3 = Color3.fromRGB(54, 28, 75)
    end
end

local function startFly()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        button.Text = "PERSONAGEM NÃO ENCONTRADO"
        task.delay(2, function()
            if button.Parent and not enabled then
                button.Text = "AUTO FLY BALL: DESLIGADO"
            end
        end)
        return
    end

    if not getBall() then
        button.Text = "BOLA NÃO ENCONTRADA"
        task.delay(2, function()
            if button.Parent and not enabled then
                button.Text = "AUTO FLY BALL: DESLIGADO"
            end
        end)
        return
    end

    stopFly()
    character = player.Character
    root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    attachment = Instance.new("Attachment")
    attachment.Name = "TurboHubAutoFlyAttachment"
    attachment.Parent = root

    velocity = Instance.new("LinearVelocity")
    velocity.Name = "TurboHubAutoFlyVelocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    velocity.VectorVelocity = Vector3.zero
    velocity.MaxForce = math.huge
    velocity.Parent = root

    enabled = true
    button.Text = "AUTO FLY BALL: LIGADO"
    button.BackgroundColor3 = Color3.fromRGB(120, 45, 165)

    flyConnection = RunService.Heartbeat:Connect(function()
        if not enabled or not velocity then return end
        local currentCharacter = player.Character
        local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
        local ball = getBall()
        if not currentRoot or not ball then
            velocity.VectorVelocity = Vector3.zero
            return
        end

        local target = ball.Position + Vector3.new(0, HEIGHT, 0)
        local offset = target - currentRoot.Position
        if offset.Magnitude <= STOP_DISTANCE then
            velocity.VectorVelocity = Vector3.zero
        else
            velocity.VectorVelocity = offset.Unit * SPEED
        end
    end)
end

button.Activated:Connect(function()
    if enabled then
        stopFly()
    else
        startFly()
    end
end)

player.CharacterAdded:Connect(function()
    stopFly()
end)

gui.Destroying:Connect(stopFly)
print("[TurboHub Roxo BETA 1.045] Auto Fly Ball integrado ao menu principal.")
