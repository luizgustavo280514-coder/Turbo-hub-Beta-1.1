-- TurboHub Roxo | Auto Fly Ball
-- Liga/desliga o voo automatico em direcao a bola.
-- Compatibilidade depende do executor e das protecoes de fisica do jogo.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local SPEED = 58
local HEIGHT_OFFSET = 6
local STOP_DISTANCE = 5

local enabled = false
local heartbeatConnection
local velocity
local attachment
local gui

local function getRoot()
    local character = LocalPlayer.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

local function findBall()
    local preferred = {
        ball = 1,
        soccerball = 2,
        football = 3,
        bola = 4,
    }

    local best, bestRank
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name):gsub("[%s_%-]", "")
            local rank = preferred[name]
            if not rank then
                if string.find(name, "soccerball", 1, true) then rank = 5
                elseif string.find(name, "football", 1, true) then rank = 6
                elseif string.find(name, "bola", 1, true) then rank = 7
                elseif string.find(name, "ball", 1, true) then rank = 8
                end
            end
            if rank and (not bestRank or rank < bestRank) then
                best, bestRank = obj, rank
            end
        end
    end
    return best
end

local function stopFlight()
    enabled = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    if velocity then
        velocity:Destroy()
        velocity = nil
    end
    if attachment then
        attachment:Destroy()
        attachment = nil
    end
    local root = getRoot()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
    end
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function startFlight()
    local root = getRoot()
    if not root then return false, "Personagem não encontrado" end

    local ball = findBall()
    if not ball then return false, "Não encontrei a bola" end

    stopFlight()
    root = getRoot()
    if not root then return false, "Personagem não encontrado" end

    attachment = Instance.new("Attachment")
    attachment.Name = "TurboHub_AutoFly_Attachment"
    attachment.Parent = root

    velocity = Instance.new("LinearVelocity")
    velocity.Name = "TurboHub_AutoFly_Velocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    velocity.VectorVelocity = Vector3.zero
    velocity.MaxForce = math.huge
    velocity.Parent = root

    enabled = true
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        local currentRoot = getRoot()
        local currentBall = findBall()
        if not currentRoot or not currentBall then
            stopFlight()
            return
        end

        local target = currentBall.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
        local offset = target - currentRoot.Position
        local distance = offset.Magnitude

        if distance <= STOP_DISTANCE then
            velocity.VectorVelocity = Vector3.zero
        else
            velocity.VectorVelocity = offset.Unit * SPEED
        end
    end)

    return true, "VOO: LIGADO"
end

local function makeGui()
    local parent
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok then parent = result end
    end
    parent = parent or game:GetService("CoreGui")

    local old = parent:FindFirstChild("TurboHubAutoFlyBall")
    if old then old:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = "TurboHubAutoFlyBall"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(190, 76)
    frame.Position = UDim2.new(0.5, -95, 0.68, 0)
    frame.BackgroundColor3 = Color3.fromRGB(35, 18, 58)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(170, 90, 255)
    stroke.Thickness = 2
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 0, 25)
    title.Position = UDim2.fromOffset(6, 3)
    title.BackgroundTransparency = 1
    title.Text = "TURBOHUB • AUTO FLY"
    title.TextColor3 = Color3.fromRGB(235, 215, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 36)
    button.Position = UDim2.fromOffset(8, 34)
    button.BackgroundColor3 = Color3.fromRGB(115, 45, 190)
    button.Text = "LIGAR VOO"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = true
    button.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    local dragging, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    button.Activated:Connect(function()
        if enabled then
            stopFlight()
            button.Text = "LIGAR VOO"
            button.BackgroundColor3 = Color3.fromRGB(115, 45, 190)
        else
            local ok, message = startFlight()
            if ok then
                button.Text = "DESLIGAR VOO"
                button.BackgroundColor3 = Color3.fromRGB(165, 55, 95)
            else
                button.Text = message
                task.delay(2, function()
                    if button and button.Parent and not enabled then
                        button.Text = "LIGAR VOO"
                    end
                end)
            end
        end
    end)
end

makeGui()

LocalPlayer.CharacterAdded:Connect(function()
    stopFlight()
end)

print("[TurboHub] Auto Fly Ball carregado. Use o botão na tela.")
